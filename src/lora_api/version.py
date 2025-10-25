try:
    from importlib.metadata import version, PackageNotFoundError
except ImportError:
    from importlib_metadata import version, PackageNotFoundError

def get_version() -> str:
    try:
        return version("lora-api")
    except PackageNotFoundError:
        return "0.1.0"

