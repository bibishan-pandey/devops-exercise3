from typing import Union

from fastapi import FastAPI

app = FastAPI()


@app.get("/")
def read_root():
    return {"Hello": "World"}


@app.get("/items/{item_id}")
def read_item(item_id: int, q: Union[str, None] = None):
    return {"item_id": item_id, "q": q}


@app.get("/items/test")
def read_item(item_id: int, q: Union[str, None] = None):
    return {
        "item_id": item_id,
        "q": q,
        "post-commit": "This is a post commit API endpoint after Kubernetes deployment.",
    }
