import subprocess
import requests
import json
# process = subprocess.Popen(f"pydeps --no-output --show-deps --max-bacon=0 .".split(), cwd=run_path, stdout=subprocess.PIPE)

def get_api_gateway_url():
    api_url = subprocess.run(
        ["terraform", "output", "-raw", "api_gateway_url"], # -raw to remove quotes
        cwd='tf', # The terraform output command needs to run in the tf folder
        capture_output=True,
        text=True
    )
    return api_url.stdout.strip() # strip() removes the newline \n from the end of the url

def send_post_request(api_url, file_name):
    headers = {"Content-Type": "application/json"}
    message = {"message": "Hello World"}

    response = requests.post(
        f"{api_url}/write?file_name={file_name}",
        data=json.dumps(message),
        headers=headers
    )

    if response.status_code == 200:
        return response.json()
    else:
        return {"error": "Failed to send POST request"}

def send_get_request(api_url, file_name):
    response = requests.get(f"{api_url}/read?file_name={file_name}")

    if response.status_code == 200:
        return response.json()

if __name__ == "__main__":
    file_name = "data.json"
    api_gateway_url = get_api_gateway_url()

    post_request = send_post_request(api_gateway_url, file_name)
    print(post_request)

    get_request = send_get_request(api_gateway_url, file_name)
    print(get_request)
    # print(f"API Gateway URL: {api_gateway_url}")
    # print(f"POST URL: {api_gateway_url}/write?file_name={file_name}")
