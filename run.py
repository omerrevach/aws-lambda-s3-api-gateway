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
    
def send_post_request(api_url):
    headers = {"Content-Type": "application/json"}
    message = {"message": "Hello World"}

    response = requests.post(
        f"{api_url}/write",
        data=json.dumps(message),
        headers=headers
    )
    
    if response.status_code == 200:
        return response.json()
    else:
        return {"error": "Failed to send POST request"}

def send_get_request(api_url):
    response = requests.get(f"{api_url}/read")
    
    if response.status_code == 200:
        return response.json()

if __name__ == "__main__":
    api_gateway_url = get_api_gateway_url()
    
    post_request = send_post_request(api_gateway_url)
    print(post_request)
    
    get_request = send_get_request(api_gateway_url)
    print(get_request)
    