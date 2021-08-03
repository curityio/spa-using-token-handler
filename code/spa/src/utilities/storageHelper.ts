/*
 * Demonstrates how to manage multi tab logout by watching a local storage field
 */
export class StorageHelper {

    private readonly _key;
    private _onLoggedOut: () => Promise<void>;

    public constructor(onLoggedOut: () => Promise<void>) {

        this._key = 'demoapp.loggedout';
        this._onLoggedOut = onLoggedOut;
        this._setupCallbacks();
    }

    public setLoggedOut(state: boolean) {
        localStorage.setItem(this._key, String(state));
    }
    
    public async onChange(event: StorageEvent): Promise<void> {

        if (event.storageArea == localStorage) {
            if (event.key === this._key && event.newValue === 'true') {
                this._onLoggedOut!();
            }
        }
    }

    private _setupCallbacks(): void {
        this.onChange = this.onChange.bind(this);
    }
}