import requests


payload = {"name": "alice", "programer": "program"} # wsol mel telefoun
r = requests.post("https://reqres.in/api/users/", json=payload)
print(r)
print(r.text)