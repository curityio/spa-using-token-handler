import React, {useState} from 'react';
import {ErrorRenderer} from '../../utilities/errorRenderer';
import {RemoteError} from '../../utilities/remoteError';
import {UserInfoProps} from './userInfoProps';

export function UserInfoView(props: UserInfoProps) {

    const [userName, setUserName] = useState('');
    const [errorText, setErrorText] = useState('');

    function isButtonDisabled(): boolean {
        return false;
    }

    async function execute() {
        
        try {

            let userInfo = await props.oauthClient.getUserInfo();

            setErrorText('');
            
            if (userInfo.given_name && userInfo.family_name) {
                setUserName(`${userInfo.given_name} ${userInfo.family_name}`);
            } else {
                setUserName('No username details returned from userinfo');
            }

        } catch (e: any) {

            if (e instanceof RemoteError && e.isSessionExpiredError()) {
                props.onLoggedOut();
                return;
            }

            setUserName('');
            setErrorText(ErrorRenderer.toDisplayFormat(e));
        }
    }

    return (

        <div className='container'>
            <h2>Get User Info</h2>
            <p>The SPA sends the SameSite cookie to the OAuth Agent to get User Info</p>
            <button 
                id='getUserInfo' 
                className='btn btn-primary operationButton'
                onClick={execute}
                disabled={isButtonDisabled()}>
                    Get User Info
            </button>
            {userName &&
            <div>
                <p id='getUserInfoResult' className='alert alert-success'>{userName}</p>
            </div>}
            {errorText &&
            <div>
                <p className='alert alert-danger' id='getUserInfoErrorResult'>{errorText}</p>
            </div>}
            <hr/>
        </div>
    )
}
