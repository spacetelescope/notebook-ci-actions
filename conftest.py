from nbclient import NotebookClient

class CustomNotebookClient(NotebookClient):
    def __init__(self, *args, **kwargs):
        kwargs.setdefault("iopub_timeout", 60)  # Increase to 60 seconds
        super().__init__(*args, **kwargs)

def pytest_configure(config):
    # Tell nbval to use our custom client
    config._nbclient_class = CustomNotebookClient
