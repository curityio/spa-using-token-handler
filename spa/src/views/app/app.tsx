import React, {useEffect, useState} from 'react';
import {StorageHelper} from '../../utilities/storageHelper';
import {CallApiView} from '../callApi/callApiView';
import {ClaimsView} from '../claims/claimsView';
import {MultiTabView} from '../multiTab/multiTabView';
import {PageLoadView} from '../pageLoad/pageLoadView';
import {SignOutView} from '../signOut/signOutView';
import {StartAuthenticationView} from '../startAuthentication/startAuthenticationView';
import {TitleView} from '../title/titleView';
import {UserInfoView} from '../userInfo/userInfoView';
import {AppProps} from './appProps';
import {AppState} from './appState';

export default function App(props: AppProps) {

    const [state, setState] = useState<AppState | null>(null);
    const storage = new StorageHelper(() => multiTabLogout());

    useEffect(() => {
        startup();
        return () => cleanup();
    }, []);

    async function startup() {

        window.addEventListener('storage', storage.onChange);
        await props.viewModel.initialize();

        setState({
            isLoaded: false,
            isLoggedIn: false,
            sessionExpired: false,
        });
    }

    function cleanup() {
        window.removeEventListener('storage', storage.onChange);
    }

    function setIsLoaded() {

        setState((prevState: any) => {
            return {
                ...prevState,
                isLoaded: true,
            };
        });
    }

    function setIsLoggedIn() {

        storage.setLoggedOut(false);
        setState((prevState: any) => {
            return {
                ...prevState,
                isLoggedIn: true,
                sessionExpired: false,
            };
        });
    }

    function setIsLoggedOut() {

        storage.setLoggedOut(true);
        setState((prevState: any) => {
            return {
                ...prevState,
                isLoggedIn: false,
                sessionExpired: true,
            };
        });
    }

    /*
     * This browser tab is notified when logout occurs on another tab, then cleans up this tab's state
     */
    async function multiTabLogout() {

        await props.viewModel.oauthClient!.onLoggedOut();
        setIsLoggedOut();
    }

    /*
     * This simple app does not use React navigation and just renders the current view based on state
     */
    return (
        <>
            <TitleView />

            {/* Unauthenticated views */}
            {state && !state.isLoggedIn &&
                <>
                    <PageLoadView 
                        oauthClient={props.viewModel.oauthClient!}
                        onLoaded={setIsLoaded}
                        onLoggedIn={setIsLoggedIn}
                        onLoggedOut={setIsLoggedOut} />

                    {state.isLoaded && 
                        <>
                            <StartAuthenticationView 
                                oauthClient={props.viewModel.oauthClient!} />
                        </>
                    }
                </>
            }

            {/* Authenticated views */}
            {state && state.isLoaded && state.isLoggedIn &&
            <>
                <MultiTabView />

                <UserInfoView 
                    oauthClient={props.viewModel.oauthClient!}
                    onLoggedOut={setIsLoggedOut} />

                <ClaimsView 
                    oauthClient={props.viewModel.oauthClient!}
                    onLoggedOut={setIsLoggedOut} />

                <CallApiView 
                    apiClient={props.viewModel.apiClient!}
                    onLoggedOut={setIsLoggedOut} />

                <SignOutView 
                    oauthClient={props.viewModel.oauthClient!}
                    onLoggedOut={setIsLoggedOut} />
            </>
            }
        </>
    );
}
