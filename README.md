# TechTive

APP Name : TechTive 
Tagline: Detective for your thoughts!

Link to Backend repository: [https://github.com/GeorgeDong00/journal-app-backend/blob/feature/s3/app/main/routes.py](https://github.com/GeorgeDong00/journal-app-backend/tree/dev/main)

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

This leads them to the login page. Implemented using Firebase, the login page displays relevant errors such as user not existing, wrong password, or even wrongly formatted email. We also have an option to reset password. This sends a reset link to the user's mail if they exist on our server.

<img width="400" alt="Screenshot 2024-12-06 at 8 38 28 PM" src="https://github.com/user-attachments/assets/49bb543c-ff37-4802-8885-f50ae0183f65">
<img width="407" alt="Screenshot 2024-12-06 at 8 39 10 PM" src="https://github.com/user-attachments/assets/b9dff481-45d2-486b-992d-1a97986c4c22">

A new user can also sign up - this feature too gives all the relevant error messages - 

<img width="398" alt="Screenshot 2024-12-06 at 8 56 12 PM" src="https://github.com/user-attachments/assets/58bbe9b0-03ef-4c01-825f-995b9ef39296">

On our main screen, we have an AI generated weekly overview , a quote generator from a backend API, and our notes scroll view. 

<img width="399" alt="Screenshot 2024-12-07 at 12 33 41 AM" src="https://github.com/user-attachments/assets/15c0fa21-ab7d-4a06-a024-ab1696d07fc1">

we also have spider graphs associated to the emotions of each post, based on the sentiment analysis
<img width="388" alt="Screenshot 2024-12-07 at 12 34 05 AM" src="https://github.com/user-attachments/assets/53a3498d-687b-4bec-b19a-bfe74c21042b">

The add post button leads to our custom text editor. This allows the user to bold or italicize the text, or even change its size. The post button will edit or post the note. 

<img width="397" alt="Screenshot 2024-12-06 at 9 20 29 PM" src="https://github.com/user-attachments/assets/bafffc25-d186-4777-9b25-2e51b0bf1f75">



This is our profile page. It allows a user to change their profile image, edit their profile, and show their user stats. These stats include a bar graph of weekly notes updates, the total number of notes, the frequency of notes per week, and streak length. The edit profile button allows the user to select an image from their gallery. The edit profile allows them to change their username, password, and even email!

<img width="300" alt="Screenshot 2024-12-06 at 9 11 32 PM" src="https://github.com/user-attachments/assets/fc01fa77-fb33-4ca9-9968-f93aa27b8815">
<img width="300" alt="Screenshot 2024-12-06 at 9 14 20 PM" src="https://github.com/user-attachments/assets/eabdb497-bb0e-45d5-8fb6-a5996619aa69">
<img width="300" alt="Screenshot 2024-12-06 at 9 03 22 PM" src="https://github.com/user-attachments/assets/01ca809c-f580-482e-9a8a-f6240cd639f9">








