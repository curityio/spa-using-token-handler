export interface Configuration {
    port: number;
    jwksUri: string;
    issuer: string;
    audience: string;
    algorithm: string;
    keystoreFilePath: string;
    keystorePassword: string;
};
