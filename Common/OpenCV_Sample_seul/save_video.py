
import cv2  # openCV 라이브러리
from datetime import datetime  # 파일명에 시간을 추가하기 위한 datetime 라이브러리
import os  # 폴더 생성을 위해 추가
import re
import warnings

# 아래 경고 메세지만 무시
# warnings.filterwarnings("ignore", 
#                         message="AVCaptureDeviceTypeExternal is deprecated for Continuity Cameras.")
def fxn():
    warnings.warn("deprecated", DeprecationWarning)
    
with warnings.catch_warnings(action="ignore"):
    fxn()
    
# 웹캠 영상을 캡처하고 영상 데이터로 저장하는 함수 정의
def write_video():
    # VideoCapture 객체 생성 - 0: 맥북 카메라, 1: 핸드폰 카메라
    cap = cv2.VideoCapture(1)

    # 프레임 가로 크기 지정
    cap.set(3, 960)
    # 프레임 세로 크기 지정
    cap.set(4, 480)

    # 초당 프레임 수 설정
    fps = 20
    
    # 저장되는 영상의 가로 크기를 프레임의 가로 크기로 지정
    width = int(cap.get(3))
    # 저장되는 영상의 세로 크기를 프레임의 세로 크기로 지정
    height = int(cap.get(4))
    # macOS MP4 코덱인 MP4V로 FourCC 코드 설정
    fcc = cv2.VideoWriter_fourcc('m', 'p', '4', 'v')

    # 현재 시간을 포맷에 맞게 문자열로 변환하여 파일명에 추가
    current_time = datetime.now().strftime("%d_%H%M%S")
    # 파일명에 현재 시간 추가
    file_name = f"video_test_{current_time}.mp4"

    folder_path = "./video"

    # 만약 폴더가 존재하지 않으면 폴더 생성
    if not os.path.exists(folder_path):
        os.makedirs(folder_path)

    # VideoWriter 객체 생성 - 영상 저장 경로 설정
    out = cv2.VideoWriter(os.path.join(folder_path, file_name), fcc, fps, (width, height))

    # 카메라로부터 프레임 읽어오기
    ret, frame = cap.read()
    if not ret:
        print("Error: Failed to capture frame")
    else:
        while True:
            ret, frame = cap.read()

            # video_test라는 이름의 창에 프레임 출력
            cv2.imshow('video_test', frame)
            
            # 파일 저장
            out.write(frame)  
            
            # 입력되는 키를 k변수에 저장 - 1초마다 사용자 입력을 기다림
            k = cv2.waitKey(int(1000/fps)) & 0xff # 27은 esc키 번호
            if k == 27:
                # esc 키가 눌리면 프레임 읽기 종료
                break

            
        # VideoCapture 객체 소멸
        cap.release()
        # VideoWriter 객체 소멸
        out.release()
        # 창 닫기
        cv2.destroyAllWindows()


# write_video 함수 호출            
write_video()