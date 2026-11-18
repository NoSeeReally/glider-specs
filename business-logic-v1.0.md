# Business Logic

> Development of a web-based cooking and recipe-sharing social networking application using React, TypeScript, Vite, Tailwind CSS, and Supabase for home cooks, cooking enthusiasts, food hobbyists, and individuals interested in discovering, sharing, and improving cooking techniques and recipes.


- Allowed Platforms: Web, Android

## Project Details

- Company/Startup/Team Name: `<Team Name>`
- Project Code Name: `Glider`
- Project Short Code: `GD`
- Short Description: `A cooking-focused social networking platform where users can share recipes, document cooking experiences, discover dishes, and connect with fellow cooking enthusiasts.`
- Long Description: `Glider is a social networking platform dedicated to cooking, food preparation, and recipe discovery. It provides users with a space to publish cooking-related posts, share structured recipes, interact with other cooking enthusiasts, and document their culinary experiences. Users can explore a personalized feed, follow other contributors, like and comment on posts, and save recipes for future reference. Its distinguishing feature, Cooked It!, allows users to recreate recipes published by others and share their results, modifications, ratings, and personal experiences while maintaining attribution to the original recipe. The platform aims to build a collaborative cooking community where users can learn from one another, exchange ideas, and improve their cooking skills.`

## User Levels

> Note: Modify/rename the list of users based on the actual users that you expect to use the system.

| User Level              | Description |
| ----------------------- | ----------- |
| A. System Administrator | Maintains the system infrastructure, server configurations, database management, security settings, and regular backups. Has the highest level of technical access.|
| B. Administrator        | Manages platform operations, user accounts, application settings, content oversight, and system analytics. Can assign moderator roles and address administrative concerns. |
| C. Moderator            | Reviews reported content, investigates violations of community guidelines, and takes appropriate moderation actions such as hiding posts, removing inappropriate content, or restricting accounts.|
| D. Contributor          |Registered users who can create and manage their profiles, publish cooking-related posts and recipes, follow other users, interact with content, save recipes, and share their own cooking attempts.|
| E. Guest                | Users who are not logged in. They can browse publicly available posts, view public recipes, and explore the platform but cannot publish content or interact with other users.|

## System Requirements

1. The app shall allow users to authenticate using Google Sign-In integration.

2. The app shall allow registered users to create, edit, and manage their profiles, including their usernames, profile pictures, and biographies.

3. The app shall allow contributors to create, edit, delete, and publish cooking-related posts with photo uploads and captions.

4. The app shall allow contributors to create and share structured recipes containing ingredients, measurements, preparation instructions, servings, preparation time, and cooking time.

5. The app shall allow users to discover and interact with cooking content through a personalized feed, user following, likes, and comments.

6. The app shall allow users to search and filter recipes, save or bookmark recipes, and document their attempts at recreating recipes through the Cooked It! feature.

7. The app shall provide administrators and moderators with tools to manage users, review reported content, enforce community guidelines, and monitor platform activity through appropriate administrative interfaces.
## Required Solution Layers

1. Security and Privacy by Design. The system shall implement secure authentication, role-based access control, and database-level authorization policies. Personal information and user-generated content shall be protected in accordance with the Philippine Data Privacy Act of 2012 (RA 10173). Users shall have control over their profile visibility and personal information, with appropriate consent mechanisms, data retention policies, and account deletion procedures.

2. Authentication and Authorization. The system shall distinguish between guests, contributors, moderators, administrators, and system administrators. Access to protected resources and administrative functions shall be restricted according to assigned roles and permissions.

3. Content Management and Moderation. The system shall provide mechanisms for publishing, editing, deleting, reporting, and moderating user-generated content. Community guidelines shall be established to address spam, harassment, misleading content, and inappropriate material.

4. Data Management and Integrity. The system shall maintain relational consistency among users, posts, recipes, ingredients, comments, likes, saved recipes, and cooking attempts. Appropriate validation and database constraints shall be implemented to prevent invalid or inconsistent records.

5. Media and File Management. The system shall support secure image uploads and storage for profile pictures, cooking posts, recipes, and cooking attempts. Uploaded files shall be subject to appropriate file type, size, and access restrictions.

6. Availability and Reliability. The system shall provide reliable access to its core features, implement appropriate error handling, and maintain regular database backups and recovery procedures.

7. Usability and Accessibility. The application shall provide a responsive and intuitive interface that supports desktop and mobile web browsers, including Android devices.

## MVP Features and Access

> See the User Levels table for reference.

| Feature               | Access      |
| --------------------- | ----------- |
| 1.Browse public posts, cooking content, and recipes| A,B,C,D,E   |
| 2. User authentication and profile management| A,B,C,D     |
| 3. Create, edit, and delete cooking-related posts and recipes| A,B,C,D     |
| 4. Follow users, like posts, comment, and save recipes| A,B,C,D     |
| 5. Content moderation and review of reported posts or accounts| A,B,C       |
| 6. User account administration and platform analytics| A,B         |
| 7. System configuration, database administration, and backups| A           |

## Notes
The MVP will prioritize a responsive web application that works on desktop and Android mobile browsers. A dedicated native Android application is outside the initial development scope.

The Cooked It! feature will allow contributors to document their attempts at recreating another user's recipe, including photos, ratings, notes, and modifications. Each attempt should retain a reference to the original recipe.

Recipes shall be treated as structured content associated with posts, allowing users to publish both ordinary cooking-related posts and recipe-based posts.

The application will initially support image-based content. Video uploads, livestreaming, private messaging, AI-generated recipes, and advanced recommendation algorithms are excluded from the MVP.

Only authenticated contributors may publish content or perform social interactions. Guests may access publicly available content without an account.

All user-generated content must comply with the platform's community guidelines.

Administrative privileges must be restricted and enforced through server-side authorization rather than relying solely on frontend interface restrictions.
