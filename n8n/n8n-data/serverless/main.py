from fastapi import FastAPI
from utils.gugong import pdf2json_parser, is_gugong_json_up_to_date
import os


BASE_URL='/python-serverless'
app = FastAPI(root_path=BASE_URL)



@app.get("/gugong/update_pdf")
async def update_gugong_pdf():
    if is_gugong_json_up_to_date():
        pdf_count = len([f for f in os.listdir('./data/gugong') if f.lower().endswith('.pdf')])
        return {
            "result": "already up to date",
            "processed": False,
            "count": pdf_count
        }

    success = pdf2json_parser()
    return {
        "result": success,
        "processed": success
    }









if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8080, reload=True)
