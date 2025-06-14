# just a cpoy of the function in the webui UI > Functions > Gugong


from typing import Optional, Callable, Dict, Any, Tuple
from pydantic import BaseModel, Field
import time
import requests


def extract_event_info(
    event_emitter: Optional[Callable[[Dict[str, Any]], None]],
) -> Tuple[Optional[str], Optional[str]]:
    if not event_emitter or not hasattr(event_emitter, "__closure__"):
        return None, None
    for cell in event_emitter.__closure__:
        if isinstance(request_info := getattr(cell, "cell_contents", None), dict):
            return request_info.get("chat_id"), request_info.get("message_id")
    return None, None


class Pipe:
    class Valves(BaseModel):
        n8n_url: str = Field(
            default="http://n8n.n8n.svc.cluster.local/webhook/4c8d41aa-dd27-4d86-92da-1987ac57b34f"
        )
        input_field: str = Field(default="chatInput")
        response_field: str = Field(default="output")
        emit_interval: float = Field(
            default=2.0, description="Interval in seconds between status emissions"
        )
        enable_status_indicator: bool = Field(
            default=True, description="Enable or disable status indicator emissions"
        )

    def __init__(self):
        self.type = "pipe"
        self.id = "gugong"
        self.name = "Gugong"
        self.valves = self.Valves()
        self.last_emit_time = 0.0

    def emit_status(
        self,
        event_emitter: Optional[Callable[[Dict[str, Any]], None]],
        level: str,
        message: str,
        done: bool,
    ) -> None:
        current_time = time.time()
        if (
            event_emitter
            and self.valves.enable_status_indicator
            and (
                (current_time - self.last_emit_time) >= self.valves.emit_interval
                or done
            )
        ):
            event_emitter(
                {
                    "type": "status",
                    "data": {
                        "status": "complete" if done else "in_progress",
                        "level": level,
                        "description": message,
                        "done": done,
                    },
                }
            )
            self.last_emit_time = current_time

    def pipe(
        self,
        body: Dict[str, Any],
        user: Optional[Dict[str, Any]] = None,
        event_emitter: Optional[Callable[[Dict[str, Any]], None]] = None,
        event_call: Optional[Callable[[Dict[str, Any]], Dict[str, Any]]] = None,
    ) -> Optional[str]:
        # Emit start status
        # self.emit_status(event_emitter, "info", "Calling N8N Workflow...", False)

        chat_id, _ = extract_event_info(event_emitter)
        messages = body.get("messages", []) or []

        if not messages:
            # No messages to process
            # self.emit_status(
            #     event_emitter,
            #     "error",
            #     "No messages found in the request body",
            #     True,
            # )
            body.setdefault("messages", []).append(
                {
                    "role": "assistant",
                    "content": "No messages found in the request body",
                }
            )
            return None

        # Get the latest user question
        question = messages[-1].get("content", "")

        try:
            # Prepare headers and payload
            headers = {
                "n8n-chat-key": "5ZEG518vj58nOn94BKusjP3DuuksL0Im",
                "Content-Type": "application/json",
            }
            payload: Dict[str, Any] = {"sessionId": f"{chat_id}"}
            payload[self.valves.input_field] = question

            # Sync call to N8N
            response = requests.post(
                self.valves.n8n_url,
                json=payload,
                headers=headers,
                timeout=60,
            )
            if response.status_code != 200:
                raise Exception(f"Error: {response.status_code} - {response.text}")

            # Extract N8N response
            n8n_response = response.json()[0].get(self.valves.response_field)
            if n8n_response is None:
                raise Exception("No response field returned from N8N")

            # Append assistant message
            body.setdefault("messages", []).append(
                {"role": "assistant", "content": n8n_response}
            )

        except Exception as e:
            # Emit error status and return error dict
            # self.emit_status(
            #     event_emitter,
            #     "error",
            #     f"Error during sequence execution: {str(e)}",
            #     True,
            # )
            return {"error": str(e)}  # type: ignore

        # Emit completion status
        # self.emit_status(event_emitter, "info", "Complete", True)
        return n8n_response
