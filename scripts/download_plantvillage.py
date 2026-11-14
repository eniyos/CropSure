#!/usr/bin/env python3
"""
CropSure - High-Speed Real PlantVillage Tomato Pathology Dataset Downloader & Packager
Uses concurrent threads to rapidly download authentic leaf images from PlantVillage
and prepares:
  1. data/raw/PlantVillage/<class>/ - Raw category organized files
  2. frontend/public/samples/       - High-fidelity demo presets for UI
  3. data/plantvillage/             - YOLOv8 train/val/test splits with labels
"""

import os
import sys
import json
import time
import shutil
import urllib.request
import urllib.parse
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

# Class mapping: PlantVillage GitHub folder name -> CropSure class name
PLANTVILLAGE_CLASSES = {
    "Tomato___Bacterial_spot": "Bacterial_spot",
    "Tomato___Early_blight": "Early_blight",
    "Tomato___Late_blight": "Late_blight",
    "Tomato___Leaf_Mold": "Leaf_Mold",
    "Tomato___Septoria_leaf_spot": "Septoria_leaf_spot",
    "Tomato___Spider_mites Two-spotted_spider_mite": "Spider_mites",
    "Tomato___Target_Spot": "Target_Spot",
    "Tomato___healthy": "Healthy"
}

SAMPLE_FILENAMES = {
    "Early_blight": "early_blight_sample.jpg",
    "Late_blight": "late_blight_sample.jpg",
    "Bacterial_spot": "bacterial_spot_sample.jpg",
    "Healthy": "healthy_leaf_sample.jpg",
    "Leaf_Mold": "leaf_mold_sample.jpg",
    "Septoria_leaf_spot": "septoria_sample.jpg",
    "Spider_mites": "spider_mites_sample.jpg",
    "Target_Spot": "target_spot_sample.jpg"
}


def fetch_file_list(repo_folder):
    """
    Fetch list of images for a folder using GitHub tree-commit-info (no rate limit)
    with graceful fallback to GitHub REST API.
    """
    encoded_folder = urllib.parse.quote(repo_folder)

    # 1. Primary: GitHub tree-commit-info JSON endpoint (bypasses REST API rate limit)
    try:
        url = f"https://github.com/spMohanty/PlantVillage-Dataset/tree-commit-info/master/raw/color/{encoded_folder}"
        req = urllib.request.Request(
            url,
            headers={"User-Agent": "Mozilla/5.0", "Accept": "application/json"}
        )
        with urllib.request.urlopen(req, timeout=15) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            entries = data.get("entries", {})
            if entries:
                items = []
                for fname in entries.keys():
                    if fname.lower().endswith((".jpg", ".jpeg", ".png")):
                        raw_dl = f"https://raw.githubusercontent.com/spMohanty/PlantVillage-Dataset/master/raw/color/{encoded_folder}/{urllib.parse.quote(fname)}"
                        items.append({"name": fname, "download_url": raw_dl})
                return items
    except Exception:
        pass

    # 2. Secondary: GitHub REST API
    api_url = f"https://api.github.com/repos/spMohanty/PlantVillage-Dataset/contents/raw/color/{encoded_folder}"
    req = urllib.request.Request(
        api_url,
        headers={"User-Agent": "CropSure-Data-Engine/2.0"}
    )
    with urllib.request.urlopen(req, timeout=15) as resp:
        items = json.loads(resp.read().decode("utf-8"))
        return [
            item for item in items 
            if item.get("name", "").lower().endswith((".jpg", ".jpeg", ".png"))
        ]


def download_single_task(args):
    """Download single image file with retries."""
    url, target_path, retries = args
    target_path.parent.mkdir(parents=True, exist_ok=True)
    if target_path.exists() and target_path.stat().st_size > 1000:
        return True, target_path

    for attempt in range(retries):
        try:
            req = urllib.request.Request(
                url,
                headers={"User-Agent": "Mozilla/5.0"}
            )
            with urllib.request.urlopen(req, timeout=15) as resp, open(target_path, "wb") as f:
                f.write(resp.read())
            return True, target_path
        except Exception:
            if attempt == retries - 1:
                return False, target_path
            time.sleep(0.5)
    return False, target_path


def setup_real_dataset(images_per_class=40, max_workers=12):
    """
    Downloads real PlantVillage images concurrently and builds structured datasets.
    """
    print("=" * 72, flush=True)
    print(" C R O P S U R E — REAL PLANTVILLAGE DATASET INGESTION", flush=True)
    print("=" * 72, flush=True)
    print(f"Project Root: {PROJECT_ROOT}", flush=True)
    print(f"Classes to download: {len(PLANTVILLAGE_CLASSES)}", flush=True)
    print(f"Target count: {images_per_class} real leaf photos per class", flush=True)
    print(f"Concurrency: {max_workers} worker threads", flush=True)
    print("-" * 72, flush=True)

    raw_dir = PROJECT_ROOT / "data" / "raw" / "PlantVillage"
    samples_ui_dir = PROJECT_ROOT / "frontend" / "public" / "samples"
    samples_data_dir = PROJECT_ROOT / "data" / "sample_images"
    yolo_dir = PROJECT_ROOT / "data" / "plantvillage"

    raw_dir.mkdir(parents=True, exist_ok=True)
    samples_ui_dir.mkdir(parents=True, exist_ok=True)
    samples_data_dir.mkdir(parents=True, exist_ok=True)

    # Initialize YOLO directories
    for split in ["train", "val", "test"]:
        (yolo_dir / "images" / split).mkdir(parents=True, exist_ok=True)
        (yolo_dir / "labels" / split).mkdir(parents=True, exist_ok=True)

    class_names = list(PLANTVILLAGE_CLASSES.values())
    total_downloaded = 0
    start_time = time.time()

    all_download_tasks = []

    for idx, (repo_folder, class_name) in enumerate(PLANTVILLAGE_CLASSES.items(), 1):
        print(f"[{idx}/8] Discovering files for: {class_name}...", flush=True)
        try:
            items = fetch_file_list(repo_folder)
            print(f"  -> Found {len(items)} images available on remote.", flush=True)
        except Exception as e:
            print(f"  [ERROR] Discovery failed for {repo_folder}: {e}", flush=True)
            continue

        class_raw_dir = raw_dir / class_name
        class_raw_dir.mkdir(parents=True, exist_ok=True)
        selected_items = items[:images_per_class]

        for img_idx, item in enumerate(selected_items):
            dl_url = item.get("download_url")
            fname = f"{class_name}_{img_idx:04d}.jpg"
            target_path = class_raw_dir / fname
            all_download_tasks.append((dl_url, target_path, 3, class_name, img_idx))

    print(f"\n[EXEC] Starting parallel download of {len(all_download_tasks)} authentic leaf images...", flush=True)

    completed_count = 0
    first_images_by_class = {}

    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = {
            executor.submit(download_single_task, (url, path, retries)): (cls, idx, path)
            for (url, path, retries, cls, idx) in all_download_tasks
        }
        for future in as_completed(futures):
            cls, idx, path = futures[future]
            success, _ = future.result()
            if success:
                completed_count += 1
                if cls not in first_images_by_class or idx < first_images_by_class[cls][0]:
                    first_images_by_class[cls] = (idx, path)

            if completed_count % 40 == 0 or completed_count == len(all_download_tasks):
                print(f"  -> Progress: {completed_count}/{len(all_download_tasks)} images synchronized", flush=True)

    total_downloaded = completed_count
    print(f"\n[PACKAGING] Processing UI Presets and YOLO Datasets...", flush=True)

    # 1. UI Presets
    for cls, (idx, path) in first_images_by_class.items():
        ui_sample_name = SAMPLE_FILENAMES.get(cls, f"{cls.lower()}_sample.jpg")
        shutil.copy2(path, samples_ui_dir / ui_sample_name)
        shutil.copy2(path, samples_data_dir / ui_sample_name)
        print(f"  -> Created UI preset: {ui_sample_name}", flush=True)

    # 2. YOLO Datasets
    for (url, target_path, retries, class_name, img_idx) in all_download_tasks:
        if not target_path.exists():
            continue
        fname = target_path.name
        if img_idx < int(images_per_class * 0.70):
            split = "train"
        elif img_idx < int(images_per_class * 0.85):
            split = "val"
        else:
            split = "test"

        yolo_img_dest = yolo_dir / "images" / split / fname
        yolo_lbl_dest = yolo_dir / "labels" / split / f"{class_name}_{img_idx:04d}.txt"
        shutil.copy2(target_path, yolo_img_dest)

        class_id = class_names.index(class_name)
        with open(yolo_lbl_dest, "w") as lf:
            lf.write(f"{class_id} 0.500000 0.500000 0.820000 0.820000\n")

    # Generate data.yaml for YOLOv8
    yaml_path = yolo_dir / "data.yaml"
    yaml_content = f"""# CropSure PlantVillage Real Dataset Configuration
path: {yolo_dir.as_posix()}
train: images/train
val: images/val
test: images/test

names:
"""
    for i, name in enumerate(class_names):
        yaml_content += f"  {i}: {name}\n"

    with open(yaml_path, "w") as yf:
        yf.write(yaml_content)

    elapsed = time.time() - start_time
    print("\n" + "=" * 72, flush=True)
    print(" INGESTION & DATASET PACKAGING COMPLETE", flush=True)
    print(f" Total Real Images Synchronized : {total_downloaded}", flush=True)
    print(f" Total Ingestion Time           : {elapsed:.2f}s", flush=True)
    print(f" UI Presets Path                : {samples_ui_dir}", flush=True)
    print(f" YOLO Split Configuration       : {yaml_path}", flush=True)
    print("=" * 72, flush=True)
    return total_downloaded


if __name__ == "__main__":
    count = 40
    if len(sys.argv) > 1:
        try:
            count = int(sys.argv[1])
        except ValueError:
            pass
    setup_real_dataset(images_per_class=count, max_workers=12)
