#!/bin/bash

grpc_tools_ruby_protoc --ruby_out=lib --grpc_out=lib ./proto/planner.proto