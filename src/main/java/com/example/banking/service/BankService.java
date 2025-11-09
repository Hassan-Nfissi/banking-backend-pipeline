package com.example.banking.service;

import com.example.banking.model.*;
import com.example.banking.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class BankService {
    private final UserRepository userRepo;
    private final AccountRepository accountRepo;

    public User registerUser(String name, String email) {
        User u = userRepo.save(new User(null, name, email));
        accountRepo.save(new Account(null, 0.0, u));
        return u;
    }

    public Account deposit(Long accountId, double amount) {
        Account acc = accountRepo.findById(accountId).orElseThrow();
        acc.setBalance(acc.getBalance() + amount);
        return accountRepo.save(acc);
    }

    public Account withdraw(Long accountId, double amount) {
        Account acc = accountRepo.findById(accountId).orElseThrow();
        if (acc.getBalance() < amount)
            throw new RuntimeException("Insufficient funds");
        acc.setBalance(acc.getBalance() - amount);
        return accountRepo.save(acc);
    }

    public void transfer(Long fromId, Long toId, double amount) {
        withdraw(fromId, amount);
        deposit(toId, amount);
    }

    public Account getAccount(Long id) {
        return accountRepo.findById(id).orElseThrow();
    }
}

