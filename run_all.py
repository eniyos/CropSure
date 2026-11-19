import os
import sys
import time
import signal
import subprocess
from pathlib import Path

# Force UTF-8 on Windows console if supported
if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stderr.reconfigure(encoding="utf-8")
    except Exception:
        pass

# Set project paths
ROOT_DIR = Path(__file__).resolve().parent
FRONTEND_DIR = ROOT_DIR / "frontend"
BACKEND_SCRIPT = ROOT_DIR / "backend" / "run.py"
REDIRECTOR_SCRIPT = ROOT_DIR / "scripts" / "port_3001_redirect.py"

def main():
    print("=" * 65)
    print("  [CROPSURE] Starting Platform (Backend + Frontend)")
    print("=" * 65)

    # Environment setup
    env = os.environ.copy()
    env["PYTHONPATH"] = str(ROOT_DIR)
    env["KMP_DUPLICATE_LIB_OK"] = "TRUE"

    # Determine npm executable
    npm_cmd = "npm.cmd" if os.name == "nt" else "npm"

    # Launch Backend
    print("\n[1/3] Launching Backend API server on http://localhost:5005...")
    backend_proc = subprocess.Popen(
        [sys.executable, str(BACKEND_SCRIPT)],
        cwd=str(ROOT_DIR),
        env=env
    )

    # Brief delay to allow backend to bind socket
    time.sleep(2)

    # Launch Frontend
    print("[2/3] Launching Frontend Dashboard on http://localhost:3000...")
    frontend_proc = subprocess.Popen(
        [npm_cmd, "run", "dev"],
        cwd=str(FRONTEND_DIR),
        env=env
    )

    # Launch Port 3001 redirector if script exists
    redirect_proc = None
    if REDIRECTOR_SCRIPT.exists():
        print("[3/3] Starting port 3001 redirector...")
        try:
            redirect_proc = subprocess.Popen(
                [sys.executable, str(REDIRECTOR_SCRIPT)],
                cwd=str(ROOT_DIR),
                env=env
            )
        except Exception:
            redirect_proc = None

    print("\n" + "=" * 65)
    print("  [SUCCESS] CropSure Platform is RUNNING!")
    print("  * Frontend Web UI:  http://localhost:3000")
    print("  * Backup Port UI:   http://localhost:3001")
    print("  * Backend REST API: http://localhost:5005")
    print("  * API Health Check: http://localhost:5005/api/health")
    print("  * Model Telemetry:  http://localhost:5005/api/models/status")
    print("=" * 65)
    print("  Press Ctrl+C to stop all services safely.\n")

    def handle_sigint(signum, frame):
        print("\nShutting down CropSure services...")
        backend_proc.terminate()
        frontend_proc.terminate()
        if redirect_proc:
            redirect_proc.terminate()
        try:
            backend_proc.wait(timeout=5)
            frontend_proc.wait(timeout=5)
            if redirect_proc:
                redirect_proc.wait(timeout=3)
        except Exception:
            backend_proc.kill()
            frontend_proc.kill()
            if redirect_proc:
                redirect_proc.kill()
        print("Done. Goodbye!")
        sys.exit(0)

    signal.signal(signal.SIGINT, handle_sigint)
    if hasattr(signal, "SIGTERM"):
        signal.signal(signal.SIGTERM, handle_sigint)

    try:
        while True:
            b_poll = backend_proc.poll()
            f_poll = frontend_proc.poll()
            if b_poll is not None:
                print(f"Backend process exited with code {b_poll}")
                break
            if f_poll is not None:
                print(f"Frontend process exited with code {f_poll}")
                break
            time.sleep(1)
    except KeyboardInterrupt:
        handle_sigint(None, None)

if __name__ == "__main__":
    main()
