flowchart TD
%% Actors
Customer[/"Customer/Contractor"/]
Admin[/"Admin/Finance Team"/]

    %% Core System
    Platform["eBuildify Platform"]

    %% External Systems
    PaymentGateway["Payment Gateway"]
    ExternalAPIs["External APIs<br/>(MTN MoMo, Vodafone,<br/>Telecel, Banks)"]
    Maps["Google Maps API"]
    Notify["Notification Services<br/>(SMS/Email)"]

    %% Customer to Platform
    Customer -->|Orders<br/>Registration<br/>Payment Info| Platform
    Platform -->|Order Confirmations<br/>Delivery Updates<br/>Receipts| Customer

    %% Admin to Platform
    Admin -->|Product Updates<br/>Stock Levels<br/>Credit Approvals| Platform
    Platform -->|Reports<br/>Analytics<br/>Notifications| Admin

    %% Platform to Payment Gateway
    Platform -->|Payment Requests| PaymentGateway
    PaymentGateway -->|Payment Confirmations| Platform

    %% Payment Gateway to External APIs
    PaymentGateway -->|API Interaction| ExternalAPIs

    %% Platform to Maps
    Platform -->|Delivery Addresses<br/>Distance Queries| Maps
    Maps -->|Route Info<br/>Geocoding Data| Platform

    %% Platform to Notification
    Platform -->|SMS/Email Notifications| Notify
    Notify -->|Delivery Confirmations| Customer
