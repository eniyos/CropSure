import base64
import io
import numpy as np
from PIL import Image

ALLOWED_EXTENSIONS = {"png", "jpg", "jpeg", "webp", "bmp"}
MAX_IMAGE_SIZE_BYTES = 16 * 1024 * 1024  # 16 MB


def validate_image(file_or_bytes, max_size_mb=16.0):
    """
    Validate image file integrity, format, and dimensions.

    Args:
        file_or_bytes: FileStorage, file-like object, bytes, or PIL Image.
        max_size_mb (float): Maximum permitted file size in megabytes.

    Returns:
        tuple (bool, str, dict): (is_valid, error_message, metadata_dict)
    """
    max_size = int(max_size_mb * 1024 * 1024)

    try:
        if isinstance(file_or_bytes, Image.Image):
            img = file_or_bytes
            width, height = img.size
            return True, "", {
                "format": img.format or "RAW_PIL",
                "mode": img.mode,
                "width": width,
                "height": height,
                "size_bytes": None
            }

        if hasattr(file_or_bytes, "read"):
            # File-like object (e.g. Werkzeug FileStorage)
            content = file_or_bytes.read()
            file_or_bytes.seek(0)  # Reset pointer for subsequent reads
        elif isinstance(file_or_bytes, (bytes, bytearray)):
            content = bytes(file_or_bytes)
        else:
            return False, "Unsupported file input type.", {}

        # Size check
        if len(content) > max_size:
            return False, f"File size ({len(content) / (1024*1024):.1f}MB) exceeds {max_size_mb}MB limit.", {}

        if len(content) == 0:
            return False, "Empty file received.", {}

        # Open and verify image
        img_buffer = io.BytesIO(content)
        with Image.open(img_buffer) as img:
            img.verify()

        # Reopen for metadata extraction since verify closes or invalidates some attributes
        img_buffer.seek(0)
        with Image.open(img_buffer) as img:
            width, height = img.size
            img_format = (img.format or "").lower()

            if img_format not in ALLOWED_EXTENSIONS:
                return False, f"Unsupported image format: {img_format}. Allowed: {ALLOWED_EXTENSIONS}", {}

            if width < 32 or height < 32:
                return False, f"Image dimensions ({width}x{height}) are too small (minimum 32x32).", {}

            metadata = {
                "format": img_format,
                "mode": img.mode,
                "width": width,
                "height": height,
                "size_bytes": len(content)
            }
            return True, "", metadata

    except Exception as exc:
        return False, f"Invalid or corrupted image: {str(exc)}", {}


def load_image(image_input):
    """
    Standardize various image inputs (bytes, base64, file-like, numpy) into a RGB PIL Image.

    Args:
        image_input: PIL Image, bytes, base64 string, or numpy array.

    Returns:
        PIL.Image.Image in RGB mode.
    """
    if isinstance(image_input, Image.Image):
        return image_input.convert("RGB")

    if isinstance(image_input, np.ndarray):
        if image_input.dtype != np.uint8:
            image_input = np.clip(image_input, 0, 255).astype(np.uint8)
        if len(image_input.shape) == 2:  # Grayscale
            return Image.fromarray(image_input).convert("RGB")
        elif len(image_input.shape) == 3:
            if image_input.shape[2] == 4:  # RGBA
                return Image.fromarray(image_input).convert("RGB")
            return Image.fromarray(image_input)

    if isinstance(image_input, (bytes, bytearray)):
        return Image.open(io.BytesIO(image_input)).convert("RGB")

    if isinstance(image_input, str):
        # Base64 string handling
        return base64_to_image(image_input)

    if hasattr(image_input, "read"):
        content = image_input.read()
        if hasattr(image_input, "seek"):
            image_input.seek(0)
        return Image.open(io.BytesIO(content)).convert("RGB")

    raise ValueError(f"Cannot convert {type(image_input)} to PIL Image.")


def preprocess_for_detection(image, target_size=(640, 640)):
    """
    Preprocess image for YOLOv8 model inference.

    Args:
        image: PIL Image or numpy array.
        target_size: Desired resolution (width, height), default (640, 640).

    Returns:
        dict: Processed image array, scaling factors, original shape.
    """
    pil_img = load_image(image)
    orig_w, orig_h = pil_img.size

    # Resize preserving aspect ratio with letterboxing or direct resize
    resized = pil_img.resize(target_size, Image.Resampling.BILINEAR)
    img_array = np.array(resized, dtype=np.float32) / 255.0

    return {
        "image_array": img_array,
        "pil_image": resized,
        "original_shape": (orig_h, orig_w),
        "target_shape": (target_size[1], target_size[0]),
        "scale_x": target_size[0] / orig_w,
        "scale_y": target_size[1] / orig_h
    }


def preprocess_for_gradcam(image, target_size=(224, 224)):
    """
    Preprocess image for standard PyTorch torchvision backbones (ResNet) with ImageNet normalization.

    Args:
        image: PIL Image or numpy array.
        target_size: Desired resolution, default (224, 224).

    Returns:
        torch.Tensor: Normalized tensor with shape (1, 3, target_size[0], target_size[1]).
    """
    import torch
    pil_img = load_image(image)
    resized = pil_img.resize(target_size, Image.Resampling.BILINEAR)

    # Convert to numpy float32 normalized to [0, 1]
    arr = np.array(resized, dtype=np.float32) / 255.0

    # ImageNet standard normalization
    mean = np.array([0.485, 0.456, 0.406], dtype=np.float32)
    std = np.array([0.229, 0.224, 0.225], dtype=np.float32)
    normalized = (arr - mean) / std

    # Rearrange HWC to CHW and add batch dimension -> NCHW
    tensor = torch.tensor(normalized.transpose(2, 0, 1), dtype=torch.float32).unsqueeze(0)
    return tensor


def image_to_base64(image, format="JPEG", quality=90):
    """
    Encode PIL Image or numpy array to base64 string.

    Args:
        image: PIL Image or numpy array.
        format (str): 'JPEG' or 'PNG'.
        quality (int): Compression quality (1-100).

    Returns:
        str: Base64 data URI string.
    """
    pil_img = load_image(image)
    buffer = io.BytesIO()

    # Save to buffer
    save_format = format.upper()
    if save_format in ["JPG", "JPEG"]:
        pil_img.save(buffer, format="JPEG", quality=quality, optimize=True)
        mime = "image/jpeg"
    elif save_format == "PNG":
        pil_img.save(buffer, format="PNG", optimize=True)
        mime = "image/png"
    else:
        pil_img.save(buffer, format=save_format)
        mime = f"image/{save_format.lower()}"

    encoded = base64.b64encode(buffer.getvalue()).decode("utf-8")
    return f"data:{mime};base64,{encoded}"


def base64_to_image(b64_string):
    """
    Decode base64 string (with or without data URI prefix) into a PIL Image.

    Args:
        b64_string (str): Base64 image string.

    Returns:
        PIL.Image.Image: Decoded RGB image.
    """
    if not isinstance(b64_string, str):
        raise ValueError("Expected base64 string.")

    # Strip data URI header if present (e.g. data:image/jpeg;base64,...)
    if "," in b64_string:
        b64_string = b64_string.split(",", 1)[1]

    raw_bytes = base64.b64decode(b64_string.strip())
    return Image.open(io.BytesIO(raw_bytes)).convert("RGB")
