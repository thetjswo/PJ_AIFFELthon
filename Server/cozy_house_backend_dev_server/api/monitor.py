import asyncio
import base64

import cv2
from fastapi import APIRouter, WebSocket, WebSocketDisconnect

from cctv_server import camera_module

router = APIRouter()


@router.websocket("/realtime_stream")
async def app_stream(websocket: WebSocket):
    await websocket.accept()

    try:
        async for frame_data in camera_module('realtime_streaming'):

            encoded = cv2.imencode('.jpg', frame_data)[1]
            data = base64.b64encode(encoded).decode('utf-8')

            await websocket.send_text(data)
    except WebSocketDisconnect:
        print("Client Disconnected!")

    except Exception as e:
        print(f"Error occurred: {e}")
