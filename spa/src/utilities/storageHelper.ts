/*
 * Demonstrates how to manage multi tab logout by watching a local storage field
 */
export class StorageHelper {

    private readonly key;
    private onLoggedOut: () => Promise<void>;

    public constructor(onLoggedOut: () => Promise<void>) {

        this.key = 'demoapp.loggedout';
        this.onLoggedOut = onLoggedOut;
        this.setupCallbacks();
    }

    public setLoggedOut(state: boolean) {
        localStorage.setItem(this.key, String(state));
    }
    
    public async onChange(event: StorageEvent): Promise<void> {

        if (event.storageArea == localStorage) {
            if (event.key === this.key && event.newValue === 'true') {
                this.onLoggedOut!();
            }
        }
    }

    private setupCallbacks(): void {
        this.onChange = this.onChange.bind(this);
    }
}