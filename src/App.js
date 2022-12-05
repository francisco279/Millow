import { useEffect, useState } from 'react';
import { ethers } from 'ethers';

// Components
import Navigation from './components/Navigation';
import Search from './components/Search';
import Home from './components/Home';

// ABIs
import RealEstate from './abis/RealEstate.json'
import Escrow from './abis/Escrow.json'

// Config
import config from './config.json';

function App() {

  //State variables
  const [account, setAccount] = useState(null);

  //Function to connect to blockchain
  const loadBlockchain = async() =>
  {
    const provider = new ethers.providers.Web3Provider(window.ethereum); // Our web3 provider

    //Set up and update the account every time the metamask account changes
    window.ethereum.on('accountsChanged', async () =>
    {
      const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' }); // Get accounts
      const account  = ethers.utils.getAddress(accounts[0])
      setAccount(account);
    })
  }

  useEffect ( () => 
  {
    loadBlockchain()
  }, [])

  return (
    <div>

      <Navigation account={account} setAccount={setAccount}></Navigation>
      <div className='cards__section'>

        <h3>Welcome to Millow</h3>

      </div>

    </div>
  );
}

export default App;
