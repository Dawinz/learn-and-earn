import mongoose, { Document, Schema } from 'mongoose';

export interface IPayout extends Document {
  deviceId: string;
  mobileNumber: string;
  coins: number;
  amountUsd: number;
  status: 'pending' | 'approved' | 'paid' | 'rejected' | 'canceled';
  reason?: string;
  requestedAt: Date;
  approvedAt?: Date;
  paidAt?: Date;
  rejectedAt?: Date;
  userRegisteredAt?: Date;
  txRef?: string;
  adminNotes?: string;
  signature: string;
  nonce: string;
}

const PayoutSchema = new Schema<IPayout>({
  deviceId: {
    type: String,
    required: true,
    index: true
  },
  mobileNumber: {
    type: String,
    required: true
  },
  coins: {
    type: Number,
    required: true,
    min: 0
  },
  amountUsd: {
    type: Number,
    required: true,
    min: 0
  },
  status: {
    type: String,
    enum: ['pending', 'approved', 'paid', 'rejected', 'canceled'],
    default: 'pending',
    index: true
  },
  reason: {
    type: String
  },
  requestedAt: {
    type: Date,
    default: Date.now,
    index: true
  },
  approvedAt: {
    type: Date
  },
  paidAt: {
    type: Date
  },
  rejectedAt: {
    type: Date
  },
  userRegisteredAt: {
    type: Date
  },
  txRef: {
    type: String
  },
  adminNotes: {
    type: String
  },
  signature: {
    type: String,
    required: true
  },
  nonce: {
    type: String,
    required: true
  }
});

export default mongoose.model<IPayout>('Payout', PayoutSchema);
