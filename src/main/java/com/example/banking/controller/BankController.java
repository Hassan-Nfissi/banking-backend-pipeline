package com.example.banking.controller;

import com.example.banking.model.*;
import com.example.banking.service.BankService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/bank")
@RequiredArgsConstructor
public class BankController {
    private final BankService bankService;

    @PostMapping("/register")
    public User register(@RequestParam String name, @RequestParam String email) {
        return bankService.registerUser(name, email);
    }

    @PostMapping("/deposit/{id}")
    public Account deposit(@PathVariable Long id, @RequestParam double amount) {
        return bankService.deposit(id, amount);
    }

    @PostMapping("/withdraw/{id}")
    public Account withdraw(@PathVariable Long id, @RequestParam double amount) {
        return bankService.withdraw(id, amount);
    }

    @PostMapping("/transfer")
    public String transfer(@RequestParam Long from, @RequestParam Long to, @RequestParam double amount) {
        bankService.transfer(from, to, amount);
        return "Transfer successful";
    }

    @GetMapping("/account/{id}")
    public Account getAccount(@PathVariable Long id) {
        return bankService.getAccount(id);
    }
}

