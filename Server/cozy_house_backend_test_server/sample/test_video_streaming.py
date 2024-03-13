import websockets
import asyncio

import cv2
import base64

import warnings

# 아래 경고 메세지만 무시
warnings.filterwarnings("ignore", 
                        message="AVCaptureDeviceTypeExternal is deprecated for Continuity Cameras*")

port = 5000

print("Started server on port : ", port)

async def transmit(websocket, path):
    print("Client Connected !")
    try :
        cap = cv2.VideoCapture(1) # connect to smartphone camera

        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                print("Error: Failed to capture frame")
                break

            encoded = cv2.imencode('.jpg', frame)[1]

            data = str(base64.b64encode(encoded))
            data = data[2:len(data)-1] # 'b...'
            
            await websocket.send(data)
            
            # # for debugging
            # cv2.imshow("Transimission", frame)
            # # 1초마다 사용자 입력 기다림
            # if cv2.waitKey(int(1000/fps)) & 0xFF == ord('q'):   # q 누르면 비디오 화면 종료 
            #     break
            
        cap.release()
        
    except websockets.exceptions.ConnectionClosedError as e:
        print("Client Disconnected !")
        cap.release()
    
    except Exception as e:
        print(f"Someting went Wrong: {e}")
        cap.release()

start_server = websockets.serve(transmit, host="192.168.100.159", port=port)

asyncio.get_event_loop().run_until_complete(start_server)
asyncio.get_event_loop().run_forever()