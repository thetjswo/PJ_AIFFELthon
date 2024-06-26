import asyncio

from fastapi import APIRouter, Request, HTTPException
from pydantic import BaseModel
from json import JSONDecodeError

from crud import policy


router = APIRouter()


class PolicyFlagRequest(BaseModel):
    uid: str


class PolicyFlagResponse(BaseModel):
    detection_yn: bool


@router.post("/change_flag", response_model=PolicyFlagResponse)
async def userinfo_route(request: Request):
    try:
        request_data = await request.json()
        policy_request = PolicyFlagRequest(**request_data)
    except JSONDecodeError:
        raise HTTPException(status_code=400, detail="Invalid JSON format")

    result = policy.change_policy_flag(policy_request)

    response_data = PolicyFlagResponse(detection_yn=result)

    # video_handler.py로 object detection 하는 경우 주석 해제
    # task = asyncio.create_task(object_detection_with_tracking(policy_request.uid))

    return response_data


# @router.post("/get_flag", response_model=PolicyFlagResponse)
# async def userinfo_route(request: Request):
#     try:
#         request_data = await request.json()
#         policy_request = PolicyFlagRequest(**request_data)
#     except JSONDecodeError:
#         raise HTTPException(status_code=400, detail="Invalid JSON format")
#
#     result = policy.get_policy_flag(policy_request)
#
#     response_data = PolicyFlagResponse(detection_yn=result)
#
#     # obj_detect = VideoHandler()
#     # await obj_detect.detection_flag_receive_loop(policy_request.uid)
#     # await obj_detect.object_detection_loop()
#
#     return response_data
