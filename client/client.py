import requests

host = "Service URL"
url = f"{host}/v1/recommend"

request_data = {
                "page": "index",
                "data": {"ip_address": "e12345"}
}

res = requests.post(url, json=request_data)

if res.status_code == 200:
    print(res.json())
else:
    print("Error: ", res.text)
