# Hulu Bedeje - Software Requirements Specification (SRS)

## 1. Introduction
### 1.1 Purpose
This Software Requirements Specification (SRS) document outlines the comprehensive functional, non-functional, and structural architecture for Hulu Bedeje, an on-demand home-maintenance marketplace engineered exclusively as a unified web application for the urban Ethiopian market. The platform connects urban households and offices with vetted blue-collar professionals—including certified electricians, licensed plumbers, professional painters, and specialized cleaners—accessed entirely through responsive web browser viewports.

### 1.2 Scope
The system is built on a single-codebase web architecture utilizing a modern full-stack web framework (Next.js / React with Tailwind CSS) backed by a relational database and API server. It manages multi-factor authentication, Role-Based Access Control (RBAC), geospatial service discovery, booking lifecycle state machines, and administrative KYC verification within a unified web portal. Real-time online payment gateway and automated escrow integrations are explicitly excluded from this iteration due to administrative onboarding constraints.

## 2. Statement of Problem
Urban centers across Ethiopia, notably Addis Ababa, experience rapid urban expansion coupled with fragmented, manual service delivery mechanisms. Sourcing reliable domestic or commercial maintenance professionals relies exclusively on informal word-of-mouth networks, unverified street-side interactions, or physical bulletin boards. This legacy approach induces severe structural friction:
*   **Severe Safety & Security Vulnerabilities:** Homeowners face substantial exposure when inviting unverified individuals into private residences without institutional background checks, digital tracking, or formal identity accountability.
*   **Pricing Opacity & Exploitative Intermediaries:** Pricing is heavily distorted by informal middlemen (Dalala), who impose arbitrary, unstandardized service fees without quality guarantees.
*   **Operational Coordination Deficits:** Extended downtime occurs due to a complete lack of centralized scheduling, live tracking, transparent dispute channels, or structured transaction execution infrastructure.

## 3. Objectives (Solutions)
*   **Institutional Digital Vetting & Trust Architecture:** Deploy rigorous KYC documentation workflows (National ID verification, sub-city residential validation, and professional certification checks) to construct a trusted talent pool.
*   **Transparent Service Discovery & Pricing:** Establish a structured digital service catalog featuring transparent, standardized base tiers or fixed inspection-fee models to eliminate intermediary price inflation.
*   **Unified Web-Based Dispatch & Lifecycle Tracking:** Replace manual phone coordination with intelligent web-based booking requests and centralized administrative monitoring loops.
*   **Manual Settlement Protocol:** Implement a structured offline settlement verification framework (cash-on-completion or direct transfer validation) to ensure clear financial closing without third-party payment gateway bureaucratic dependencies.

## 4. Key Features
*   **Unified Single-Web Ecosystem:** Fluid role-based routing delivering dedicated customer, artisan, and administrative dashboards from a single web URL and codebase.
*   **Geospatial Neighborhood Matching Engine:** Location-based filtering, radius calculation, and automated provider sorting aligned with municipal sub-districts and neighborhoods (e.g., Bole, Kazanchis, CMC, Ayat).
*   **Deterministic Booking Lifecycle Management:** Finite-state transition tracking monitoring requests from initial creation through dispatch, execution, and manual settlement.
*   **Centralized Administrative KYC & Audit Dashboard:** Secure administrative control panels for reviewing professional credentials, managing platform categories, and auditing operational ledgers.
*   **In-App Communication & Dispute Routing:** Secure text interface allowing masked customer-artisan coordination alongside administrative dispute flagging tools.
*   **Dual-Directional Quality Control & Rating Loop:** Comprehensive feedback infrastructure evaluating service performance to dynamically isolate or suspend underperforming providers.

## 5. Actors
*   **Customer (Homeowner / Commercial Property Manager):** End-users who authenticate into the web platform, browse service catalogs, submit localized booking requests, track dispatch status, and settle service fees directly with the artisan upon completion.
*   **Service Provider (Artisan / Professional):** Vetted blue-collar operators who manage availability statuses, accept or decline incoming web dispatch requests, navigate via integrated mapping coordinates, fulfill maintenance contracts, and confirm settlement receipts.
*   **System Administrator:** Platform operators who review and approve KYC submissions, manage master category taxonomies, resolve customer-artisan disputes, audit operational ledgers, and monitor system health.

## 6. Limitations
*   **Web-Only Environment:** Native mobile device hardware integrations (such as background native push services or direct device sensors) are constrained to progressive web app (PWA) capabilities and browser constraints.
*   **Payment Integration Exclusion:** Due to local regulatory requirements, banking compliance, and bureaucratic merchant onboarding timelines, automated online payment gateway APIs and digital escrow features are omitted from the current scope. Financial transactions rely on manual cash-on-completion or direct offline settlement verification.
*   **Cellular Data & Infrastructure Dependencies:** Full real-time tracking requires consistent internet connectivity across urban coverage zones.
*   **User Digital Literacy Barriers:** Adoption requires baseline digital competence among end-users to successfully navigate web booking interfaces.
*   **Urban Physical Logistics Constraints:** Severe traffic congestion and seasonal infrastructural disruptions within Addis Ababa can occasionally affect real-time artisan transit estimations.

## 7. Methodology
Teraet follows an Agile Iterative Software Development Life Cycle (SDLC) designed for continuous deployment, scalability, and robust maintenance:
*   **Requirements Analysis & Formal Specification:** Establishing structural boundaries, user stories, security models, and data dictionaries.
*   **System Architecture & Database Modeling:** Designing relational entity-relationship structures, API routing protocols, and unified web route guards.
*   **Core Implementation & Coding:** Constructing the unified Next.js presentation layout alongside asynchronous Python/Node.js backend services.
*   **Integration & Comprehensive Quality Assurance:** Executing automated unit tests, API integration suites, and multi-viewport web responsiveness checks.
*   **Deployment & Release Management:** Distributing production builds to cloud web hosting environments (e.g., Vercel) and backend VPS servers.

## 8. Functional Requirements
*   **FR-01: Multi-Factor Web Authentication:** The system must provide secure registration and session management via mobile phone numbers authenticated through automated One-Time Passwords (OTP).
*   **FR-02: Artisan KYC Document Submission:** Service providers must be enabled to digitally upload National ID documentation, residency verification forms, professional reference credentials, and portfolio samples via web file upload components.
*   **FR-03: Hierarchical Service Catalog Navigation:** Users must be able to explore categorized maintenance domains (Electrical, Plumbing, HVAC, Carpentry, Deep Cleaning) with clear scope descriptions on the web portal.
*   **FR-04: Granular Booking Submission Engine:** Customers must be able to draft service requests detailing problem descriptions, image attachments, geographic pinpoints, and scheduled time windows via a responsive web form.
*   **FR-05: Administrative Dispatch Control:** Administrators must be provided web interfaces to view unassigned booking queues and execute manual or automated provider assignments.
*   **FR-06: Finite Booking State Lifecycle Management:** The system must strictly enforce and update request statuses sequentially: Requested -> Accepted by Artisan -> En Route -> Arrived/In Progress -> Completed -> Settled & Reviewed.
*   **FR-07: Bilateral Rating & Review Processing:** Upon job closure, customers and artisans must be able to submit numerical star ratings and qualitative text reviews stored immutably against user profiles.

## 9. Non-Functional Requirements
*   **NFR-01: Fluid Web Responsiveness:** User interfaces must scale dynamically across heterogeneous display geometries, spanning wide desktop monitors, tablet viewports, and mobile smartphone web browsers.
*   **NFR-02: Rigorous Security & Data Privacy:** All data in transit must be secured via TLS 1.3 encryption, and sensitive data fields (passwords, PII, personal records) must be encrypted at rest within the database layer. Role-Based Access Control (RBAC) route guards must prevent unauthorized page access.
*   **NFR-03: High-Performance Response Latency:** Core API endpoints serving catalog data, user profiles, and booking creations must resolve in under two hundred milliseconds under normal operational loads.
*   **NFR-04: System Availability & Redundancy:** Backend infrastructure must target 99.9% uptime availability backed by automated database snapshots and error-logging pipelines.
*   **NFR-05: Maintainability & Modular Clean Architecture:** The source codebase must enforce strict separation of concerns (separating UI components, route protection middleware, and database services) to guarantee long-term maintainability.

## 10. Testing and Evaluation Used
*   **Unit Testing:** Validating isolated backend controllers, utility functions, and database query models against edge cases and malformed payloads.
*   **Integration Testing:** Executing end-to-end API communication checks confirming data integrity between web client interfaces, server middleware, and database instances.
*   **Cross-Browser UI Inspection:** Inspecting layout rendering behavior across major web browsers (Chrome, Safari, Firefox, Edge) and simulated mobile device viewports.
*   **End-to-End Simulation Protocols:** Running complete staging simulations tracking a web user request from form submission through artisan dispatch, job completion, and manual settlement verification.

## 11. Class Diagram
```plaintext
+-----------------------+       1--*       +-----------------------+
|         User          |----------------> |        Booking        |
+-----------------------+                  +-----------------------+
| - id: UUID            |                  | - id: UUID            |
| - name: String        |                  | - customer_id: UUID   |
| - phone: String       |                  | - artisan_id: UUID    |
| - role: Enum          |                  | - category: String    |
| - created_at: Date    |                  | - description: String |
+-----------------------+                  | - status: Enum        |
            |                              | - scheduled_date: Date|
            | 1                            +-----------------------+
            |                                          |
            | 1                                        | *
+-----------------------+                              |
|        Artisan        | <----------------------------+
+-----------------------+
| - id: UUID            |
| - user_id: UUID       |
| - category_id: UUID   |
| - verification_status |
| - rating: Float       |
| - is_online: Boolean  |
+-----------------------+
```

## 12. Technologies Used
*   **Frontend Web Framework:** Next.js (React) with Tailwind CSS deployed for unified web browsing.
*   **Backend Application Runtime:** Node.js (Express framework) or Python (FastAPI) handling asynchronous RESTful endpoint routing and middleware execution.
*   **Database & Geospatial Engine:** PostgreSQL configured with the PostGIS extension for relational integrity and spatial radius querying.
*   **Storage & Asset Management:** Cloudinary or secure object storage buckets for handling high-resolution user uploads, KYC paperwork, and portfolio images.
*   **Hosting & Infrastructure:** Vercel for unified web static and server-side rendered deployment paired with enterprise cloud VPS providers for backend container deployment.

## 13. UI (User Interface Layouts)
*   **Customer Web Portal:** Built on a clean, minimalist design system optimized for mobile and desktop web browsers, featuring prominent service category cards, dynamic location inputs, multi-step booking modal forms, and an active request dashboard.
*   **Artisan Web Companion View:** A high-utility, responsive web interface featuring incoming job alert summaries, prominent "Accept/Decline" action buttons, and task status toggles accessible via browser.
*   **Super-Admin Control Dashboard:** A dense, wide-viewport tabular data grid displaying pending artisan KYC verification requests, dispute ticket logs, system-wide dispatch queues, and granular status filter controls.

## 14. Unique Features
*   **Localized Informal-to-Digital Transformation:** Systematically converts unstructured, reputation-based street trades into structured, highly accountable digital micro-enterprises.
*   **Gateway-Free MVP Execution:** Bypasses heavy financial regulatory onboarding hurdles by utilizing manual settlement verification, enabling immediate operational launch.
*   **Unified Single-App Web Architecture:** Leverages a single Next.js codebase to power consumer booking portals, artisan job managers, and admin dashboards concurrently under one domain via strict Role-Based Access Control (RBAC).

## 15. Conclusion
The Teraet web platform establishes a rigorous engineering specification for modernizing urban maintenance logistics in Ethiopia. By uniting a clean unified web framework, uncompromising KYC verification workflows, geospatial matching engines, and manual settlement mechanics, the system comprehensively resolves structural market inefficiencies and trust barriers while eliminating bureaucratic payment integration dependencies.
