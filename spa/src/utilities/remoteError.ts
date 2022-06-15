/*
 * A simple error object for remote problems
 */
export class RemoteError extends Error {

    private readonly status: number;
    private readonly code: string;

    public constructor(status: number, code: string, message: string) {
        super(message);
        this.status = status;
        this.code = code;
    }

    public getStatus(): number {
        return this.status;
    }

    public getCode(): string {
        return this.code;
    }

    public toDisplayFormat(): string {

        const parts = [];
        if (this.status) {
            parts.push(`Status: ${this.status}`);
        }

        if (this.code) {
            parts.push(`Code: ${this.code}`);
        }

        parts.push(this.message);
        return parts.join(', ');
    }
}
