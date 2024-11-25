import Button from "../../../ui/Button";
import Modal from "../../../ui/Modal";
import { ModalHeader, ModalTitle, ModalCloseBtn, ModalBody } from "../../../ui/Modal/utils";
import { useAuth } from "../../../../hooks/useAuth";
import './index.css';

const Wallets : WalletType[] = [
    {
        icon:'/assets/images/wallets/nfid.png',
        name:'NFID',
        method:'ii'
    },
    {
        icon:'/assets/images/wallets/bifinity.png',
        name:'BIFINITY',
        method:'ii'
    },
    {
        icon:'/assets/images/wallets/plug.png',
        name:'PLUG',
        method:'plug'
    },
    {
        icon:'/assets/images/wallets/ii.png',
        name:'INTERNET IDENTITY',
        method:'ii'
    }
]

export default function ConnectWallet({closeModal} : {closeModal:()=>void}) {
    const auth = useAuth();
    return (
        <Modal onClose={closeModal}>
            <ModalHeader>
                <ModalTitle>Connect Wallet</ModalTitle>
                <ModalCloseBtn/>
            </ModalHeader>
            <ModalBody>
                <div className="flex flex-col gap-4 w-full lg:py-6">
                    {
                        Wallets.map(wallet => (
                            <Button variant="secondary" key={wallet.name} className="wallet-button" onClick={()=>auth?.login(wallet.method)}>
                                <div className="wallet-button-container">
                                    <span>{wallet.name}</span>
                                    <img src={wallet.icon} alt={wallet.name} loading='lazy' width={40} height={40} className="wallet-icon"/>
                                </div>
                            </Button>
                        ))
                    }
                </div>
            </ModalBody>
        </Modal>
    )
}