# 🚀 Quote Editor (Production-Grade Rails SaaS)

🌐 **Live Application**  
👉 https://www.hassanrails.site

---

## 🧠 Architecture

---

## ⚙️ Tech Stack

- **Backend:** Ruby on Rails 7
- **Database:** PostgreSQL (AWS RDS)
- **Caching & WebSockets:** Redis (AWS ElastiCache)
- **Infrastructure:** AWS EC2, Application Load Balancer (ALB)
- **Web Server:** Nginx (Reverse Proxy)
- **App Server:** Puma
- **Frontend:** Turbo (Drive, Frames, Streams)
- **DNS:** Namecheap

---

## 🔥 Features

- ⚡ Real-time updates using **Turbo Streams (ActionCable + Redis)**
- 🏢 Multi-tenant architecture (**Company-based isolation**)
- 👨‍💼 Role-based access:
  - Super Admin
  - Company Admin
- 🟢 Live online users counter (WebSocket-powered)
- 🔒 Secure HTTPS deployment with custom domain
- 🔄 CI/CD pipeline (GitHub Actions → EC2 deployment)

---

## 📦 Deployment Architecture

- ALB handles HTTPS (SSL via AWS ACM)
- Nginx acts as reverse proxy for HTTP traffic
- Rails runs on Puma (port 3000)
- Redis used for:
  - ActionCable
  - Caching
- PostgreSQL (RDS) for persistent storage
- Security Groups restrict direct EC2 access

---

## 🐞 Production Issues Faced & Solutions

### 1. WebSocket (ActionCable) Not Working Behind ALB

**Issue:**  
`/cable` requests were not upgrading to WebSocket

**Root Cause:**  
ALB + Nginx not forwarding upgrade headers properly

**Solution:**
- Configured Nginx with WebSocket headers
- Routed WebSocket traffic via ALB → Rails (port 3000)
- Increased ALB idle timeout

---

### 2. Turbo Streams / Users Count Not Updating

**Root Cause:**  
WebSocket connection failure

**Solution:**  
Resolved ActionCable connectivity issue

---

### 3. ALB Target Group Misconfiguration

**Issue:**  
App stuck loading

**Root Cause:**  
Deleted/misconfigured target group

**Solution:**
- Recreated target group (port 3000)
- Reattached to ALB listener
- Verified health checks (`/up`)

---

### 4. Host Authorization Error (Production)

**Issue:**  
Rails blocking requests from ALB/EC2

**Solution:**  
Configured allowed hosts in production environment

---

## 🔐 Security

- 🚫 Direct EC2 access restricted (only via ALB)
- 🔒 No public exposure of Rails port (3000)
- 🔁 Forced HTTPS redirect (80 → 443)

---

## 🚀 Future Improvements

- 🐳 Dockerize application (Docker + Docker Compose)
- 📈 Auto Scaling Group (ASG)
- ⚙️ Background jobs with Sidekiq
- 📊 Monitoring with AWS CloudWatch

---

## 🧠 Key Learnings

- Real-world debugging of ALB + WebSocket issues
- Production-grade AWS architecture design
- Handling live production failures & recovery
- Importance of correct load balancer + target group configuration

---

## 👨‍💻 Author

**Muhammad Hassan Obaid**  
Ruby on Rails Developer | AWS Enthusiast

---

## ⭐ Support

If you like this project, consider giving it a ⭐ on GitHub!
