import subprocess
import sys
from shutil import which


def main():
    # URL
    if len(sys.argv) >= 2:
        url = sys.argv[1].strip()
    else:
        url = input("Pega la URL de SoundCloud: ").strip()

    if not url:
        print("ERROR: URL vacía.")
        sys.exit(1)

    if which("ffmpeg") is None:
        print("Aviso: ffmpeg no encontrado. No es crítico si no conviertes.\n")

    # Prioridad de formatos (SIN convertir):
    # 1) WAV real
    # 2) M4A (AAC)
    # 3) MP3
    # 4) lo que haya
    format_selector = (
        "bestaudio[ext=wav]/"
        "bestaudio[ext=m4a]/"
        "bestaudio[ext=mp3]/"
        "bestaudio"
    )

    cmd = [
        sys.executable, "-m", "yt_dlp",
        "-f", format_selector,
        "--yes-playlist",
        "--ignore-errors",
        "--no-post-overwrites",
        "--add-metadata",
        "--embed-thumbnail",
        "-o", "%(playlist_title)s/%(uploader)s - %(title)s.%(ext)s",
        url
    ]

    print("\nDescargando el mejor audio REAL y compatible (sin convertir)...")
    print("Prioridad:", format_selector)
    print()

    try:
        subprocess.run(cmd, check=True)
        print("\nOK. Descarga terminada.")
    except subprocess.CalledProcessError as e:
        print("\nERROR: yt-dlp falló con código", e.returncode)
        sys.exit(e.returncode)


if __name__ == "__main__":
    main()
