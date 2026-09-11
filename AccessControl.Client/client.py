import asyncio
import websockets
import json
import uuid
import os
import time

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
USERS_FILE = os.path.join(BASE_DIR, "users.json")
DICT_FILE = os.path.join(BASE_DIR, "property_dictionary.json")
USER_PROPS_FILE = os.path.join(BASE_DIR, "user_properties.json")

# ---------------- USERS ----------------

def load_users():
    if os.path.exists(USERS_FILE):
        with open(USERS_FILE, "r") as f:
            return json.load(f)

    # теперь id не нужен — username является ключом
    users = [
        {"username": "ivanov"},
        {"username": "petrov"}
    ]

    with open(USERS_FILE, "w") as f:
        json.dump(users, f, indent=2)

    return users

# ---------------- PROPERTY DICTIONARY ----------------

def load_property_dictionary():
    if os.path.exists(DICT_FILE):
        with open(DICT_FILE, "r") as f:
            return json.load(f)

    dictionary = [
        {
            "id": str(uuid.uuid4()),
            "propertyCode": "full_name",
            "title": "ФИО",
            "type": "string",
            "isRequired": True,
            "defaultValue": "",
            "description": "Полное имя пользователя"
        },
        {
            "id": str(uuid.uuid4()),
            "propertyCode": "email",
            "title": "Email",
            "type": "string",
            "isRequired": False,
            "defaultValue": "",
            "description": "Электронная почта"
        }
    ]

    with open(DICT_FILE, "w") as f:
        json.dump(dictionary, f, indent=2)

    return dictionary

# ---------------- USER PROPERTIES ----------------

def load_user_properties(users):
    if os.path.exists(USER_PROPS_FILE):
        with open(USER_PROPS_FILE, "r") as f:
            return json.load(f)

    # теперь ключ — username
    props = {}
    for u in users:
        username = u["username"]
        props[username] = {
            "full_name": f"{username.capitalize()} ФИО",
            "email": f"{username}@example.com"
        }

    with open(USER_PROPS_FILE, "w") as f:
        json.dump(props, f, indent=2)

    return props

# ---------------- MAIN WS CLIENT ----------------

async def run_client():
    uri = "ws://localhost:5000/ws?clientId=kadry"

    while True:
        try:
            print("Connecting to server...")
            async with websockets.connect(uri, ping_interval=None) as ws:
                print("WS connected as 'kadry'")

                users = load_users()
                dictionary = load_property_dictionary()
                user_props = load_user_properties(users)

                while True:
                    msg = await ws.recv()
                    print("\n=== Received RPC request ===")
                    print(msg)

                    data = json.loads(msg)
                    req_id = data.get("requestId")
                    action = data.get("action")
                    payload = data.get("payload", {})

                    if data.get("type") != "request":
                        continue

                    # --- 1. Список пользователей ---
                    if action == "SyncUsers":
                        print(f"[RPC] Server requested USERS → {len(users)} items")
                        print(json.dumps(users, indent=2, ensure_ascii=False))

                        await ws.send(json.dumps({
                            "type": "response",
                            "requestId": req_id,
                            "payload": {"users": users}
                        }))
                        print("[RPC] Sent users list")

                    # --- 2. Справочник свойств ---
                    elif action == "SyncUserPropertyDictionary":
                        print(f"[RPC] Server requested PROPERTY DICTIONARY → {len(dictionary)} items")
                        print(json.dumps(dictionary, indent=2, ensure_ascii=False))

                        await ws.send(json.dumps({
                            "type": "response",
                            "requestId": req_id,
                            "payload": {"propertyDictionary": dictionary}
                        }))
                        print("[RPC] Sent property dictionary")

                    # --- 3. Свойства конкретного пользователя ---
                    elif action == "SyncUserProperties":
                        username = payload.get("userId")  # теперь userId = username
                        props = user_props.get(username, {})

                        print("\n===== RPC: SyncUserProperties =====")
                        print(f"Запрошены свойства пользователя: {username}")
                        print(f"Количество свойств: {len(props)}")

                        if props:
                            print("Свойства:")
                            print(json.dumps(props, indent=2, ensure_ascii=False))
                        else:
                            print("Нет свойств для этого пользователя")

                        response_payload = {
                            "userId": username,
                            "properties": props
                        }

                        print("\n>>> Отправляем ответ клиенту:")
                        print(json.dumps(response_payload, indent=2, ensure_ascii=False))

                        await ws.send(json.dumps({
                            "type": "response",
                            "requestId": req_id,
                            "payload": response_payload
                        }))
                        print(f"[RPC] Свойства пользователя '{username}' отправлены")

                    # --- 4. Неизвестное действие ---
                    else:
                        print(f"[RPC] Unknown action: {action}")

                        await ws.send(json.dumps({
                            "type": "response",
                            "requestId": req_id,
                            "error": f"Unknown action: {action}"
                        }))
                        print("[RPC] Sent error response")

        except Exception as ex:
            print("Connection failed:", ex)
            print("Retrying in 3 seconds...")
            time.sleep(3)

asyncio.run(run_client())
