import { useEffect, useState } from 'react';
import { ethers } from 'ethers';

// Components
import Navigation from './components/Navigation';
import Search     from './components/Search';
import Home       from './components/Home';

// ABIs
import RealEstate from './abis/RealEstate.json'
import Escrow     from './abis/Escrow.json'

// Config
import config     from './config.json';

function App() {

  //State variables
  const [account,   setAccount] = useState(null); //Account
  const [provider, setProvider] = useState(null); //web3 provider
  const [escrow,     setEscrow] = useState(null); //Escrow contract 
  const [homes,       setHomes] = useState([]); //Escrow contract 
  //Function to connect to blockchain
  const loadBlockchain = async() =>
  {
    const provider = new ethers.providers.Web3Provider(window.ethereum); // Our web3 provider
    setProvider(provider);

    //Connect to blockchain and smart contracts
    const network = await provider.getNetwork();
    //Contracts instances 
    // require contract address, contract abi and provider 
    //RealEstate contract
    const realEstate = new ethers.Contract(config[31337].realEstate.address, RealEstate, provider)

    //Get the total supply (total properties)
    const totalSupply = await realEstate.totalSupply()
    
    //Escrow contract
    const escrow      = new ethers.Contract(config[31337].escrow.address, Escrow, provider)
    setEscrow(escrow);

    //Listing properties 
    const homes = []

    for(var i = 1; i <= totalSupply; i++)
    {
      const uri      = await realEstate.tokenURI(i) //Get the token uri
      const response = await fetch(uri)             // Get the token object from the uri  
      const metadata = await response.json()        // Get the json from the response
      homes.push(metadata)
    }

    setHomes(homes)


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
      <Search></Search>
      <div className='cards__section'>

        <h3>Home for you</h3>

        <hr />

        <div className='cards'>
          {homes.map((home, index) =>
          (
            <div className='card' key={index}>
            <div className='card__image'>
              <img src={home.image} alt='Home'></img>
            </div>
            <div className='card__info'>
              <h4>{home.attributes[0].value} ETH</h4>
              <p>
                <strong>{home.attributes[2].value}</strong> bds |
                <strong>{home.attributes[3].value}</strong> ba  |
                <strong>{home.attributes[4].value}</strong> sqft
              </p>
              <p>{home.address}</p>
            </div>
          </div>
          ))}
            
        </div>

      </div>

    </div>
  );
}

export default App;
