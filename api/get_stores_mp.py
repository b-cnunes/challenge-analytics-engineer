import requests
import csv
import os

URL = "https://api.mercadopago.com"

def search_stores(user_id, access_token, params=None):
    """
    Searches for all stores of a user in Mercado Pago.

    Args:
        user_id (str): The user ID.
        access_token (str): The API access token.
    
    Returns:
        list: List of stores in JSON
    """
    headers = {
        "Authorization": f"Bearer {access_token}"
    }
  
    try:
        response = requests.get(f"{URL}/users/{user_id}/stores/search", headers=headers, params=params)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.HTTPError as errh:
        print(f"Error HTTP: {errh}")
        return None


def get_store(access_token, store_id):
    """  
    Gets details of a specific store.

    Args:
        store_id (str): The store ID.
        access_token (str): The API access token.

    Returns:
        dict: Store data in JSON.
    """
    headers = {
        "Authorization": f"Bearer {access_token}"
    }
    try:
        response = requests.get(f"{URL}/stores/{store_id}", headers=headers)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.HTTPError as errh:
        print(f"Error HTTP: {errh}")
        return None

def flat_store_data(store_data):
    """
    Transforms the result of the Json stores into flat format

    Args:
        store_data (dict): Store data in JSON. 
    
    Returns:
        dict: Store data in flat format
    """
    flattened = []
    
    store_id = store_data.get("id", "")
    store_name = store_data.get("name", "")
    store_date_creation = store_data.get("date_creation", "")
    location = store_data.get("location", {})
    address = location.get("address_line", "")
    reference = location.get("reference", "")
    latitude = location.get("latitude", "")
    longitude = location.get("longitude", "")
    city = location.get("city", "")
    state = location.get("state_id", "")
    
    business_hours = store_data.get("business_hours", {})
    days_of_week = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']
    
    for day in days_of_week:
        day_data = business_hours.get(day, [])
        if day_data:
            for schedule in day_data:
                flattened.append({
                    "id": store_id,
                    "name": store_name,
                    "date_creation": store_date_creation,
                    "business_day": day.capitalize(),
                    "business_open_time": schedule.get('open', ''),
                    "business_close_time": schedule.get('close', ''),
                    "location_address": address,
                    "location_reference": reference,
                    "location_latitude": latitude,
                    "location_longitude": longitude,
                    "location_city": city,
                    "location_state": state
                })
    
    return flattened

def write_to_csv(data, file_name):
    """
    Write a list of dictionaries to a CSV file.

    Args:
        data (list): List of dictionaries with data.
        file_name (str): Name of the CSV file.
    Returns:
        file: File csv.
    """

    with open(file_name, "w", newline="", encoding="utf-8") as file_csv:
        writer = csv.DictWriter(file_csv, fieldnames=data[0].keys())
        writer.writeheader()
        writer.writerows(data)

    print(f"Saved file: {file_name}")


def main():
    
    user_id = ["USER_ID"]
    access_token = ["ACCESS_TOKEN"]

    stores_data = search_stores(user_id, access_token)
    if stores_data and stores_data.get("results"):
        all_stores = []

        for store in stores_data["results"]:
            store_id = store["id"]
            store_detail = get_store(access_token, store_id)
            if store_detail:
                all_stores.extend(flat_store_data(store_detail))

        if all_stores:
            write_to_csv(all_stores, "all_stores.csv")
    else:
        print("No stores found for user.")

if __name__ == "__main__":
    main()
    