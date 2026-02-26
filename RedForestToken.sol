// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RedForestToken is ERC20, Ownable {
    // ЛОГИКА: Ограничиваем максимальную транзакцию (например, 1% от эмиссии)
    uint256 public maxTransactionAmount = 10000 * 10**18; 
    uint256 public taxFee = 2; // 2% налога с каждой продажи

    constructor() ERC20("Red Forest Token", "RFRST") Ownable(msg.sender) {
        // При создании выпускаем 1 000 000 токенов на твой кошелек
        _mint(msg.sender, 1000000 * 10**18);
    }

    // Главный алгоритм: проверка условий перед каждым переводом
    function _update(address from, address to, uint256 amount) internal virtual override {
        // Если это не владелец, проверяем лимит "кита"
        if (from != owner() && to != owner()) {
            require(amount <= maxTransactionAmount, "Anti-Whale: Sliskhom mnogo dlya odnoy sdelki!");
        }

        uint256 tax = (amount * taxFee) / 100;
        uint256 amountAfterTax = amount - tax;

        super._update(from, owner(), tax); // Налог уходит владельцу (тебе)
        super._update(from, to, amountAfterTax); // Остальное — получателю
    }
}
