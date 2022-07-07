({
    getInstallStepsText: function (index) {
        const text = [{
            title: 'Authenticate',
            text: 'Prior to installation, <a href="https://dashboard.basiq.io/register" target="_blank">sign-up</a> to Basiq via our Dashboard - to generate a new and unique API key. <br /> Your API key carries many privileges, so be sure to keep it secret!',
            img: '/resource/Basiq_Connector__step1'
        },
        {
            title: 'Map fields',
            text: 'Map your email and mobile fields from Salesforce to you Basiq account. This data is required later, when you want to ask your Lead or Contact to share their financial data.',
            img: '/resource/Basiq_Connector__step2'
        },
        {
            title: 'Finalise',
            text: 'You have successfully connected your Basiq account! <a href="https://basiq.io" target="_blank">Learn how to generate a unique URL for your customer to securely share their financial data.</a> Already using Basiq?<a href="https://basiq.io" target="_blank"> Learn how to synchronise existing users with Salesforce.</a>',
            img: '/resource/Basiq_Connector__step3'
        }]

        if (index >= 0 && index < text.length) {
            return text[index];
        } else {
            return {};
        }
    },
    setHeaderTitleAndText: function (step, title, text, img) {
        const cicleElement = document.getElementById('step-circle');
        const titleElement = document.getElementById('step-title');
        const textElement = document.getElementById('step-text');
        const imgElement = document.getElementById('step-img');

        cicleElement.innerHTML = step + 1;
        titleElement.innerHTML = title;
        textElement.innerHTML = text;
        imgElement.src = img;
    }
})