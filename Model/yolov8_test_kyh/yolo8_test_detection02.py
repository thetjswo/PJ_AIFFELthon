# yolo8_test_detection

from ultralytics import YOLO
import cv2

# Load a model
model = YOLO("yolov8n.pt")  # load a pretrained model (recommended for training) : 가중치도 함께 다운로드 됨

# Open the video file
source="test_video.mp4"
cap = cv2.VideoCapture(source)

# webcam 사용 시 - 실시간 개체 추적
# cap = cv2.VideoCapture(0)

# Loop through the video frames
while cap.isOpened():
    # Read a frame from the video
    success, frame = cap.read()

    if success:
        # Run YOLOv8 inference on the frame
        results = model(frame)

        # Visualize the results on the frame
        annotated_frame = results[0].plot()

        # Display the annotated frame
        cv2.imshow("YOLOv8 Inference", annotated_frame)

        # Break the loop if 'q' is pressed
        if cv2.waitKey(1) & 0xFF == ord("q"):
            break
    else:
        # Break the loop if the end of the video is reached
        break

# Release the video capture object and close the display window
cap.release()
cv2.destroyAllWindows()  



# Use the model predict mode
# result = model.predict(source, stream=True, save=True, conf=0.6)  # return a generator of Results objects
# stream=True : 스트리밍 기능을 사용하여 메모리 효율적인 제너레이터를 생성


# [참고] Process results generator
# for result in results:
#     boxes = result.boxes  # Boxes object for bounding box outputs : 감지된 객체의 BBox 정보 가져오기
#     masks = result.masks  # Masks object for segmentation masks outputs : 객체의 세그멘테이션 마스크 정보 가져오기
#     keypoints = result.keypoints  # Keypoints object for pose outputs : 객체의 키포인트(관절) 정보 가져오기
#     probs = result.probs  # Probs object for classification outputs : 객체의 분류 확률 정보 가져오기
#     result.show()  # display to screen
#     result.save(filename='result.jpg')  # save to disk : 시각적으로 표시된 결과를 이미지 파일로 저장하여 추후 사용 가능
