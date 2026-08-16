# Habesha Freight — Vehicle, Load & Bidding API Specification

## 1. Overview
This document specifies the REST API endpoints for **Vehicle Management**, **Load Management**, **PostGIS Spatial Search**, and **Bidding** in the Habesha Freight digital logistics platform.

---

## 2. Vehicle Endpoints (`/api/vehicles`)

All vehicle endpoints require a valid JWT Bearer Token in the `Authorization` header.

### 2.1 Register a Vehicle
- **Endpoint**: `POST /api/vehicles`
- **RBAC**: `DRIVER`, `FLEET_OWNER`, `ADMIN`
- **Request Body**:
  ```json
  {
    "plate_number": "ET-3-45892",
    "vehicle_type": "SINO_TRUCK",
    "capacity_tons": 25.0
  }
  ```
- **Response (201 Created)**:
  ```json
  {
    "success": true,
    "message": "Vehicle registered successfully.",
    "data": {
      "id": "33333333-3333-4333-8333-333333333333",
      "driver_id": "22222222-2222-4222-8222-222222222222",
      "plate_number": "ET-3-45892",
      "vehicle_type": "SINO_TRUCK",
      "capacity_tons": 25.0,
      "is_active": true,
      "created_at": "2026-08-16T06:48:00.000Z"
    }
  }
  ```

### 2.2 List Accessible Vehicles
- **Endpoint**: `GET /api/vehicles`
- **RBAC**: Authenticated Users (Drivers see their own; Admins see all)
- **Response (200 OK)**:
  ```json
  {
    "success": true,
    "count": 1,
    "data": [
      {
        "id": "33333333-3333-4333-8333-333333333333",
        "plate_number": "ET-3-45892",
        "vehicle_type": "SINO_TRUCK",
        "capacity_tons": 25.0,
        "is_active": true,
        "driver_name": "Abebe Bikila",
        "driver_phone": "+251911223344"
      }
    ]
  }
  ```

---

## 3. Load Management & Spatial Discovery (`/api/loads`)

### 3.1 Post a New Load
- **Endpoint**: `POST /api/loads`
- **RBAC**: `SHIPPER`, `ADMIN`
- **Request Body**:
  ```json
  {
    "cargo_description": "Construction Cement Bags",
    "weight_tons": 15.5,
    "origin_city": "Addis Ababa",
    "destination_city": "Hawassa",
    "origin_lat": 8.9806,
    "origin_lng": 38.7578,
    "destination_lat": 7.0621,
    "destination_lng": 38.4763,
    "offered_price_etb": 45000.00
  }
  ```
- **Response (201 Created)**:
  ```json
  {
    "success": true,
    "message": "Load posted successfully.",
    "data": {
      "id": "44444444-4444-4444-8444-444444444444",
      "status": "POSTED",
      "offered_price_etb": 45000.00
    }
  }
  ```

### 3.2 Nearby Spatial Load Search (PostGIS Sub-300ms)
- **Endpoint**: `GET /api/loads/nearby`
- **Query Parameters**:
  - `lat`: Driver origin latitude (required)
  - `lng`: Driver origin longitude (required)
  - `radius_km`: Search radius in kilometers (default: 50)
  - `min_capacity`: Minimum cargo weight limit in tons (optional)
- **Example**: `GET /api/loads/nearby?lat=8.9806&lng=38.7578&radius_km=30`
- **Response (200 OK)**:
  ```json
  {
    "success": true,
    "count": 2,
    "radiusKm": 30,
    "data": [
      {
        "id": "44444444-4444-4444-8444-444444444444",
        "cargo_description": "Construction Cement Bags",
        "origin_city": "Addis Ababa",
        "destination_city": "Hawassa",
        "distance_km": 12.4,
        "offered_price_etb": 45000.00
      }
    ]
  }
  ```

---

## 4. Bidding Endpoints (`/api/bids`)

### 4.1 Place a Bid on a Load
- **Endpoint**: `POST /api/bids`
- **RBAC**: `DRIVER`, `FLEET_OWNER`, `ADMIN`
- **Request Body**:
  ```json
  {
    "load_id": "44444444-4444-4444-8444-444444444444",
    "bid_amount_etb": 42000.00
  }
  ```

### 4.2 Respond to a Bid (Accept / Reject)
- **Endpoint**: `PATCH /api/bids/:id/status`
- **RBAC**: `SHIPPER`, `ADMIN`
- **Request Body**:
  ```json
  {
    "status": "ACCEPTED"
  }
  ```
- **Behavior**: Accepting a bid updates the load status to `MATCHED` and marks competing bids as `REJECTED`.
