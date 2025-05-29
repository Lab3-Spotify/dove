import os
import fitz  # PyMuPDF
import json

def extract_text_from_pdf(file_path):
    text = ""
    try:
        with fitz.open(file_path) as doc:
            for page in doc:
                text += page.get_text()
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
    return text

def pdf2json_parser():
    try:
        folder_path = './data/gugong'
        pdf_files = [f for f in os.listdir(folder_path) if f.lower().endswith('.pdf')]

        results = []
        for pdf in pdf_files:
            full_path = os.path.join(folder_path, pdf)
            text = extract_text_from_pdf(full_path)
            results.append({
                'fileName': pdf,
                'text': text.strip()
            })

        with open(os.path.join(folder_path, 'gugong.json'), 'w', encoding='utf-8') as f:
            json.dump(results, f, ensure_ascii=False, indent=2)

        print(f"已完成處理 {len(pdf_files)} 份 PDF，輸出結果為 gugong.json")
    
        return True
    except Exception as e:
        print(f"Error: {e}")
        return False
    

def is_gugong_json_up_to_date(folder_path='./data/gugong', json_name='gugong.json') -> bool:
    """
    檢查 ./data/gugong.json 是否存在，且裡面的 fileName 與目前 data 資料夾下的 PDF 完全一致。
    """
    json_path = os.path.join(folder_path, json_name)
    if not os.path.isfile(json_path):
        return False

    try:
        with open(json_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        existing_names = { item.get('fileName') for item in data if 'fileName' in item }
        current_pdfs   = { f for f in os.listdir(folder_path) if f.lower().endswith('.pdf') }
        return existing_names == current_pdfs
    except Exception as e:
        print(f"檢查 gugong.json 時發生錯誤：{e}")
        return False