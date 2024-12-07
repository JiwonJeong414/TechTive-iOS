# TechTive

APP Name : TechTive 
Tagline: Detective for your thoughts!

Link to Backend repository: https://github.com/GeorgeDong00/journal-app-backend/blob/feature/s3/app/main/routes.py

App description : Our app is a journaling platform designed to help users understand their thoughts and emotions. Upon first use, users are guided through an onboarding process, with the option to skip and proceed to login. The login page, integrated with Firebase, supports account access, password recovery, and new account creation. The home page features motivational quotes, weekly feedback powered by ChatGPT, and a dynamic note navigation system with sentiment analysis through spider graphs. On the profile page, users can update personal details, manage their profile image, and view activity stats.

App requirements:

  Multiple screens that you can navigate between: we have several screens for the onboarding process, a signup screen, a login screen, a home screen,    a notes editor, a note analytics, a profile screen, a edit profile screen
  
  At least one scrollable view: Our notes view is scrollable and animated! 
  
  Networking integration with a backend API: our login is integrated with a firebase api. The sentiment analysis, notes and profile storage are all through the backend api. 

Features- 
We start with three onboarding screens- the user can skip them or go to the next one-   
  <img width="396" alt="Screenshot 2024-12-06 at 8 37 31 PM" src="https://github.com/user-attachments/assets/8a845f63-70f8-4c87-8805-f5a74a7f4e4f">

On the last onboarding screen, the user can click on the button to get started - 

<img width="402" alt="Screenshot 2024-12-06 at 8 37 39 PM" src="https://github.com/user-attachments/assets/b439b805-0adc-4a47-8a85-c4704bb16791">

This leads them to the login page. Implemented using Firebase, the login page displays relevant errors such as user not existing, wrong password, or even wrongly formatted email

<img width="400" alt="Screenshot 2024-12-06 at 8 38 28 PM" src="https://github.com/user-attachments/assets/49bb543c-ff37-4802-8885-f50ae0183f65">

We also have an option to reset email. This sends a reset link to the user's mail if they exist on our server. 
<img width="407" alt="Screenshot 2024-12-06 at 8 39 10 PM" src="https://github.com/user-attachments/assets/b9dff481-45d2-486b-992d-1a97986c4c22">

A new user can also sign up - this feature too gives all the relevant error messages - 
<img width="398" alt="Screenshot 2024-12-06 at 8 56 12 PM" src="https://github.com/user-attachments/assets/58bbe9b0-03ef-4c01-825f-995b9ef39296">


