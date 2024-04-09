import asyncio
import cv2


async def camera_module(task):
    try:
        cap = cv2.VideoCapture(1)
        fps = 30
        if task == 'object_detection':
            yield cap

        while True:
            ret, frame = cap.read()
            if not ret:
                print('Error: Failed to capture frame...')
                break

            if task == 'realtime_streaming':
                yield frame

            await asyncio.sleep(1 / fps)

        cap.release()

    except Exception as e:
        print(f"Error occurred: {e}")