module dao::SFFC {
    use sui::balance;
    use sui::balance::Balance;
    use sui::coin;
    use sui::coin::{Coin, from_balance, into_balance};
    use sui::object;
    use sui::random;
    use sui::random::Random;
    use sui::sui::SUI;
    use sui::transfer::{share_object, transfer, public_transfer};
    use sui::tx_context::sender;
    use std::option;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::clock::{Self,Clock};

    // 代币合约
    public struct SFFC has drop {}

    fun init(witness: SFFC, ctx: &mut TxContext) {
        let (treasury, metadata) =
            coin::create_currency(witness, 9, b"SFFC", b"", b"", option::none(), ctx);

        transfer::public_freeze_object(metadata);

        transfer::public_transfer(treasury, tx_context::sender(ctx))
    }


    // 质押合约
    public struct Stake  has key {
        id: UID,
        // 在合约存钱 都要用 Balance 来存
        amt: Balance<SFFC>
    }

    public struct AdminCap  has key {
        id: UID,
    }

    const sffc_apy = 0.1;

    fun init_stake(ctx: &mut TxContext) {
        let stake = Stake {
            id: object::new(ctx),
            amt: balance::zero(),
        };

        // 选择所有权的时候 所以人都可以玩
        share_object(stake);
        let admin = AdminCap { id: object::new(ctx) };
        transfer(admin, ctx.sender());
    }

    // 质押功能
    public entry fun add_SFFC(stake: &mut Stake, stake_time_start: clock::timestamp_ms(ctx.clock()), in: Coin<SFFC>, _: &mut TxContext) {
        let in_amt_balance = coin::into_balance(in);
        stake.amt.join(in_amt_balance);
    }

    // 解质押功能 奖励运算待完善
    public entry fun remove_SFFC(_: &AdminCap, stake: &mut Stake, stake_time_start: clock::timestamp_ms(ctx.clock()), amt: u64, ctx: &mut TxContext) {
        let out_balance = stake.amt.split(amt);
        let out_coin = coin::from_balance(out_balance, ctx);
        public_transfer(out_coin, ctx.sender());
    }
    // claim 奖励功能
    public entry fun claim(stake: &mut Stake,apy: u64, ctx: &mut TxContext) {
        let out_balance = stake.amt.split(amt);
        let out_coin = coin::from_balance(out_balance, ctx);
        public_transfer(out_coin, ctx.sender());
    }
}