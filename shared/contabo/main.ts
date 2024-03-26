
import { env, auth } from './env';
import { randomUUID } from 'crypto';


export class Contabo {
    private clientId = env.CLIENT_ID;
    private clientSecret = env.CLIENT_SECRET;
    private apiUser = env.API_USER;
    private apiPassword = env.API_PASSWORD;
    private rootPassword = env.ROOT_PASSWORD;

    constructor() { }

    async getAccessToken() {

        const body = {
            client_id: this.clientId,
            client_secret: this.clientSecret,
            username: this.apiUser,
            password: this.apiPassword,
            grant_type: "password"
        } as const as Record<string, string>;


        const url = new URL(auth.accessToken)

        const searchParams = new URLSearchParams(body).toString();

        const res = await fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: searchParams
        });

        const data = await res.json();

        if (!data.access_token) throw new Error("auth.contabo.error: No access token")
        const token = data.access_token

        return token;
    }

    // this will return all the data of all instances
    async listingInstances() {

        const url = new URL(auth.instanceUrl);
        const ACCESS_TOKEN = await this.getAccessToken();
        const res = await fetch(url, {
            headers: {
                'Authorization': `Bearer ${ACCESS_TOKEN}`,
                'x-request-id': '51A87ECD-754E-4104-9C54-D01AD0F83406'
            }
        });

        return await res.json();
    }

    async createPassword() {
        const ACCESS_TOKEN = await this.getAccessToken();
        const url = new URL(auth.secretUrl);

        const body = {
            name: 'ed-pub-key',
            value: env.SSH_KEY,
            type: 'ssh'
        }
        const res = await fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${ACCESS_TOKEN}`,
                'x-request-id': '51A87ECD-754E-4104-9C54-D01AD0F83406',
                'x-trace-id': 'lois-secret-creation'
            },

            body: JSON.stringify(body)
        });
        const data = await res.json();
        console.log("response:", data)
    }

    async listingFirstSecret() {
        const ACCESS_TOKEN = await this.getAccessToken();
        const url = new URL(auth.secretUrl);
        const res = await fetch(url, {
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${ACCESS_TOKEN}`,
                'x-request-id': '51A87ECD-754E-4104-9C54-D01AD0F83406',
                'x-trace-id': 'lois-listing-secrets'
            }
        });
        const data = await res.json();

        console.log("response:", data.data)

        return data.data[0].secretId;

    }

    async reinstallAllInstance() {
        const ACCESS_TOKEN = await this.getAccessToken();
        const instances = await this.listingInstances();

        const secretId = await this.listingFirstSecret();


        instances.data.forEach(async (instance) => {
            const uuid = randomUUID()

            const instanceId = instance.instanceId
            const url = new URL(`${auth.instanceUrl}/${instanceId}`);

            const body = {
                imageId: '4efbc0ba-2313-4fe1-842a-516f8652e729',
                sshKeys: [
                    secretId
                ],
                rootPassword: this.rootPassword
            }

            const response = await fetch(url, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${ACCESS_TOKEN}`,
                    'x-request-id': uuid,
                    'x-trace-id': 'reinstall-all'
                },
                body: JSON.stringify(body)
            })
            const data = await response.json()
            console.log("response:", data)
        })
    }

    async reinstallOneInstance(instanceId: string) {
        const ACCESS_TOKEN = await this.getAccessToken();
        const secretId = await this.listingFirstSecret();
    }
}

const ctb = new Contabo();

console.log("access token", ctb.getAccessToken())
