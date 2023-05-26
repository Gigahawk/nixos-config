{ config, pkgs, lib, inputs, system, ... }:

{
  environment.systemPackages = [
    inputs.agenix.packages."${system}".default
  ];
}


