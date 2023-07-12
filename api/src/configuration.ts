export interface Configuration {
    port: number;
    jwksUrl: string;
    issuer: string;
    audience: string;
    keystoreFilePath: string;
    keystorePassword: string;
};
