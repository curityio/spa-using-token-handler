/*
 * A simple error object for remote problems
 */
export class RemoteError extends Error {

    private readonly _status: number;
    private readonly _code: string;

    public constructor(status: number, code: string, message: string) {
        super(message);
        this._status = status;
        this._code = code;
    }

    public get status(): number {
        return this._status;
    }

    public toDisplayFormat(): string {

        const parts = [];
        if (this._status) {
            parts.push(`Status: ${this._status}`);
        }

        if (this._code) {
            parts.push(`Code: ${this._code}`);
        }

        parts.push(this.message);
        return parts.join(', ');
    }
}
