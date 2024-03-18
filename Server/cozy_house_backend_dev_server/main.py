from fastapi import FastAPI
from core import config
from backend_pre_start import create_db_tables, set_log_level, welcome_func

import logging


app = FastAPI()

# 로그 레벨 지정
set_log_level()
# DB 테이블 자동 생성
create_db_tables()
# TODO: 배포 시, 주석 처리 필수(아마도 피카츄 저작권 문제)
welcome_func()


@app.get("/")
async def root():
    return {"message": config.TEST_MESSAGE}


@app.get("/get_account_info")
async def account_inspection():
    logging.info('!!!!!!!!!!!!!!!')
    return 'hello'
