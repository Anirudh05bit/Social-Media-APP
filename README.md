# Social-Media-APP
 Software Requirements Specification 
Project Title: Advanced Social Media Platform

1. Introduction
1.1 Purpose
The purpose of this document is to describe the functional and non-functional requirements of the Social Media application. This application is  developed using Flutter and Firebase, providing essential social networking features along with unique innovative functionalities not available in a few social media platforms like Instagram .

1.2 Scope
PIXTA allows users to:
Register and authenticate securely


Share images and short videos


Like, comment, follow users


Chat in real time


Additionally, PIXTA introduces advanced features such as:


Study-focused & productivity social modes


Anti-addiction usage control


Post expiry system



2. Overall Description
2.1 Product Perspective
PIXTA is a mobile-based social networking application developed using:
Flutter (Frontend)


Firebase Authentication


Cloud Firestore


Firebase Storage


Firebase Cloud Messaging



2.2 User Classes
User Type
Description
Normal User
Can post, like, comment, chat
Creator
Can upload advanced content & analytics






3. Functional Requirements
3.1 Authentication System
User Sign-up using Email & Password


User Login / Logout


Password reset functionality


Secure authentication using Firebase Auth



3.2 User Profile Management
Profile picture upload


Bio editing


Followers & Following management


Profile analytics dashboard



3.3 Post Management
Upload photos and short videos


Caption editing


Hashtag support


Like, comment, and save posts


Delete or archive posts



3.4 Stories System
Upload 24-hour disappearing stories


View story insights


Story reactions



3.5 Reels / Short Videos
Upload short video clips


Trending reel discovery


Auto-play reels



3.6 Messaging System
Real-time chat


Image sharing in chats


Typing indicators


Online / offline status



4. Unique Features 
 4.1 Smart Study Mode
Blocks reels & entertainment feed


Allows only educational posts


Focus timer integration


Productivity statistics



4.2 AI Content Recommendation
Suggests posts based on learning interest


Personalized content feed


Intelligent creator suggestions



 4.3 Time Usage Control (Anti-Addiction Mode)
Daily time limit settings


Automatic app lock after usage limit


Weekly usage analytics


Mental wellness notifications



 4.4 Post Expiry Feature
Users can set post expiration time


Post auto-delete after selected time


Useful for temporary announcement



5. System Architecture
Frontend:
Flutter


Backend:
Firebase Authentication


Firestore Database


Firebase Storage


Firebase Cloud Functions



