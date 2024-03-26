import dotevn from "dotenv"

dotevn.config();
function config(key: string) {
    const value = process.env[key];
    if (!value) {
        throw new Error(`Missing environment variable: ${key}`);
    }
    return value;
}

export const env = {
    CLIENT_ID: config('CLIENT_ID'),
    CLIENT_SECRET: config('CLIENT_SECRET'),
    API_USER: config('API_USER'),
    API_PASSWORD: config('API_PASSWORD'),
    ROOT_PASSWORD: config('ROOT_PASSWORD'),
    SSH_KEY: config('SSH_KEY'),

}



export const auth = {
    accessToken: config('ACCESS_TOKEN_URL'),
    instanceUrl: config('INSTANCE_URL'),
    secretUrl: config('SECRET_URL'),
}