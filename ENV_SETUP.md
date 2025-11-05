# Environment Variables Setup

This project uses environment variables to manage configuration settings like API URLs.

## Setup Instructions

1. **Copy the sample environment file:**

   ```bash
   cp sample.env .env
   ```

2. **Edit the `.env` file with your actual values:**

   ```
   API_BASE_URL=http://10.17.1.5
   API_LOGIN_ENDPOINT=/api/Auth/login
   APP_NAME=IITR Hospital
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

## Environment Variables

- `API_BASE_URL` - The base URL of your API server
- `API_LOGIN_ENDPOINT` - The login endpoint path
- `APP_NAME` - The application name

## Important Notes

- The `.env` file is ignored by git (see `.gitignore`)
- Never commit your `.env` file to version control
- Use `sample.env` as a template for other developers
- The app will use default values if environment variables are not set

## Default Values

If the `.env` file is missing or a variable is not set, these defaults will be used:

- `API_BASE_URL`: `http://10.17.1.5`
- `API_LOGIN_ENDPOINT`: `/api/Auth/login`
- `APP_NAME`: `IITR Hospital`
