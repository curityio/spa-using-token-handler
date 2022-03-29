import React from 'react';

export function MultiTabView() {

    function isButtonDisabled(): boolean {
        return false;
    }

    function getDescription(): string {
        return 'All browser tabs share the SameSite cookies and use them when calling APIs';
    }
    
    async function execute() {
        window.open(location.href);
    }

    return (
        <div className='container'>
            <h2>Multi Tab Browsing</h2>
            <p>{getDescription()}</p>
            <button 
                id='multiTab' 
                className='btn btn-primary operationButton'
                onClick={execute}
                disabled={isButtonDisabled()}>
                    Open New Browser Tab
            </button>
            <hr/>
        </div>
    )
}
