/*
 * Demonstrates a way to manage multi-tab logout by watching a local storage field
 */
export class MultiTabLogout {

    private readonly key;
    private onLoggedOut: () => void;

    public constructor(onLoggedOut: () => void) {

        this.key = 'loggedout';
        this.onLoggedOut = onLoggedOut;
        this.setupCallbacks();
    }

    public initialize() {
        localStorage.removeItem(this.key);
    }

    public raiseLoggedOutEvent() {

        localStorage.setItem(this.key, 'true');
        setTimeout(() => {
            localStorage.removeItem(this.key);
        }, 500);
    }
    
    public async listenForLoggedOutEvent(event: StorageEvent): Promise<void> {

        if (event.storageArea == localStorage) {
            if (event.key === this.key && event.newValue === 'true') {
                this.onLoggedOut!();
            }
        }
    }

    private setupCallbacks(): void {
        this.listenForLoggedOutEvent = this.listenForLoggedOutEvent.bind(this);
    }
}
