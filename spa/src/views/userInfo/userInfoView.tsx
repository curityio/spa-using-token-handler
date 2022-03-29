import React, {useState} from 'react';
import {RemoteError} from '../../utilities/remoteError';
import {UserInfoProps} from './userInfoProps';
import {UserInfoState} from './userInfoState';

export function UserInfoView(props: UserInfoProps) {

    const [state, setState] = useState<UserInfoState>({
        givenName: '',
        familyName: '',
        error: null,
    });

    function isButtonDisabled(): boolean {
        return false;
    }

    function getUserFullName(): string {
        return `${state.givenName} ${state.familyName}`
    }

    async function execute() {
        
        try {

            let userInfo = await props.oauthClient.getUserInfo();
            if (userInfo.given_name && userInfo.family_name) {

                setState((state: any) => {
                    return {
                        ...state,
                        givenName: userInfo.given_name,
                        familyName: userInfo.family_name,
                        error: null,
                    };
                });

            }

        } catch (e) {

            const remoteError = e as RemoteError;
            if (remoteError) {

                if (remoteError.getStatus() === 401) {

                    // A 401 could occur if there is a leftover cookie in the browser that can no longer be processed
                    // Eg if the cookie encryption key is renewed or if the Authorization Server data is redeployed
                    // In this case we return to an unauthenticated state
                    props.onLoggedOut();

                } else {

                    setState((state: any) => {
                        return {
                            ...state,
                            error: remoteError.toDisplayFormat(),
                        };
                    });
                }
            }
        }
    }

    return (

        <div className='container'>
            <h2>Get User Info</h2>
            <p>The SPA sends the SameSite cookie to the OAuth Agent to get User Info from the ID token</p>
            <button 
                id='getUserInfo' 
                className='btn btn-primary operationButton'
                onClick={execute}
                disabled={isButtonDisabled()}>
                    Get User Info
            </button>
            {state.givenName && state.familyName &&
            <div>
                <p id='getUserInfoResult' className='alert alert-success'>{getUserFullName()}</p>
            </div>}
            {state && state.error &&
            <div>
                <p className='alert alert-danger' id='getUserInfoErrorResult'>{state.error}</p>
            </div>}
            <hr/>
        </div>
    )
}
